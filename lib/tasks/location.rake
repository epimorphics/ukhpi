# frozen_string_literal: true

require 'set'
require 'json'
require 'csv'

# Constants

NO_ESLINT = 'Failed to perform eslint step. Is eslint installed as a global npm package?'

# Helper classes

# Value class encapsulating a JSON location record
class LocationRecord
  def initialize(json)
    @json = json
  end

  def value_of(json)
    json&.fetch('value') || json
  end

  def uri
    value_of(@json['refRegion'])
  end

  def label
    value_of @json['label']
  end

  def lang
    @json['label']['xml:lang']
  end

  def container
    value_of @json['container']
  end

  def container2
    value_of @json['container2']
  end

  def container3
    value_of @json['container3']
  end

  def same
    value_of @json['same']
  end

  def type
    value_of @json['type']
  end

  def message
    value_of(@json['message'])
  end
end

# Encapsulates a particular location
class Location
  attr_reader :uri, :container, :container2, :container3, :gss, :message

  def initialize(location_record)
    @uri = location_record.uri
    @container = location_record.container
    @container2 = location_record.container2
    @container3 = location_record.container3
    @labels = {}
    @types = []
    @message = location_record.message

    update_from(location_record)
  end

  def update_from(location_record)
    add_type(location_record.type) if location_record.type
    add_label(location_record)

    return unless location_record.same

    @same = location_record.same
    match = @same.match(/([A-Z]\d+)$/)
    @gss = match[1] if match
  end

  def add_type(typ)
    @types << typ
  end

  def add_label(location_record)
    @labels[location_record.lang.to_sym] = location_record.label
  end

  def preferred_type
    admin_geo_type(@types)
      .grep_v(%r{/Borough})
      .first
  end

  def admin_geo_type(types)
    types.grep(/admingeo/).uniq
  end

  def in_wales?
    [container, container2, container3].include?('http://landregistry.data.gov.uk/id/region/wales')
  end

  # Post-condition invariant: there should be two labels, one English and
  # one Welsh. If the Welsh label is missing, assume we re-use the English
  def labels
    @labels[:cy] = @labels[:en] if in_wales? && !@labels.key?(:cy)

    @labels
  end

  def to_ruby
    'Location.new(' \
      "#{uri.inspect}, " \
      "#{@labels.inspect}, " \
      "#{preferred_type.inspect}, " \
      "#{container.inspect}, " \
      "\"#{gss}\")"
  end

  def to_json(_opts = nil)
    "{#{json_attributes}}"
  end

  def json_attributes
    [
      "uri: \"#{uri}\"",
      "labels: #{labels.to_json}",
      "gss: \"#{gss}\"",
      "container: \"#{container}\"",
      "container2: \"#{container2}\"",
      "container3: \"#{container3}\"",
      "type: \"#{preferred_type}\"",
      "message: \"#{message}\""
    ].join(', ')
  end
end

def write_locations_files(locations, all_types)
  location_names = []
  gss_index = {}

  locations.each_value do |loc|
    loc.labels.each do |lang, txt|
      location_names << { value: loc.uri, label: txt, lang: lang } unless txt.empty?
    end

    # properties[:children] = properties[:children].to_a.sort
    gss_index[loc.gss] = loc.uri if loc.gss
  end

  location_names.sort! { |l0, l1| l0[:label] <=> l1[:label] }

  puts 'Generating location files ... '
  # JavaScript module output
  open('locations-data.js', 'w') do |file|
    # file << "export const locationNames = #{location_names.to_json};\n"
    file << "export const types = #{all_types.to_a.sort.to_json};\n"
    file << "export const locations = {\n"
    sep = '  '
    locations.each do |uri, loc|
      file << "#{sep}\"#{uri}\": #{loc.to_json}"
      sep = ",\n  "
    end
    file << "\n};\n"
    # file << "export const gssIndex = #{gss_index.to_json};\n"
  end

  # Ruby module output
  open('locations-data.rb', 'w') do |file|
    file << "# rubocop:disable all\n"
    file << "module LocationsTable\n"
    file << "  def location_names\n"
    file << "    #{location_names.inspect}\n"
    file << "  end\n"
    file << "  def types\n"
    file << "    #{all_types.to_a.sort.inspect}\n"
    file << "  end\n"
    file << "  def locations\n"
    file << "    {\n"
    locations.each do |uri, loc|
      file << "    #{uri.inspect} => #{loc.to_ruby},\n"
    end
    file << "    }\n"
    file << "  end\n"
    file << "  def gss_index\n"
    file << "    #{gss_index.inspect}\n"
    file << "  end\n"
    file << "end\n"
  end
end

def process_location_data(location_data, locations, all_types)
  lr = LocationRecord.new(location_data)
  loc = locations[lr.uri]
  all_types << lr.type

  if loc
    loc.update_from(lr)
  else
    locations[lr.uri] = Location.new(lr)
  end
end

namespace :ukhpi do
  desc 'Generate the locations files by SPARQL query'
  task locations: %i[locations_query locations_generate locations_files_lint move_locations_files]

  # run the SPARQL query to generate the locations results
  task locations_query: :environment do
    query = "
      prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      prefix qb: <http://purl.org/linked-data/cube#>
      prefix hpi: <http://landregistry.data.gov.uk/def/ukhpi/>
      prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      prefix sr: <http://data.ordnancesurvey.co.uk/ontology/spatialrelations/>
      prefix owl: <http://www.w3.org/2002/07/owl#>

      select distinct ?refRegion ?label ?type ?container ?container2 ?container3 ?same {
      {
        SELECT DISTINCT ?g {
          GRAPH ?g {
            ?s hpi:refRegion ?r .
          }
        }
      }
      GRAPH ?g {
        ?obs a qb:Observation ;
          hpi:refRegion ?refRegion.
        ?refRegion rdfs:label ?label.
        ?refRegion rdf:type ?type.
        optional {?refRegion sr:within ?container.}
        optional {?refRegion sr:within/sr:within ?container2.}
        optional {?refRegion sr:within/sr:within/sr:within ?container3.}
        optional {
          ?refRegion rdfs:seeAlso ?same .
          FILTER regex(str(?same), \"statistical-geography\")
        }
      }
      }"

    squery = "#{ENV['FUSEKI'] || '/home/ian/dev/java/apache-jena-fuseki'}/bin/s-query"
    server = ENV['SERVER'] || 'https://landregistry.data.gov.uk/landregistry/query'

    puts "Running SPARQL query against server #{server}..."
    puts '(to change the destination SPARQL endpoint, set the $SERVER env variable)'
    system "#{squery} --server='#{server}' '#{query}' > query-results.json"
  end

  # Generate the locations modules in JavaScript and Ruby
  task locations_generate: :environment do
    puts 'Loading query results ...'
    sresults = JSON.parse(File.read('query-results.json'))
    locations = {}
    all_types = Set.new

    sresults['results']['bindings'].each do |result|
      process_location_data(result, locations, all_types)
    end

    # add exceptions
    location_exceptions = YAML.load_file('data/location-exceptions.yml')
    if location_exceptions.present?
      location_exceptions.each do |location_ex|
        process_location_data(location_ex, locations, all_types)
      end
    end

    write_locations_files(locations, all_types)
  end

  # Use eslint in --fix mode to re-parse the JSON output and convert it to
  # compliant ES2015
  task locations_files_lint: :environment do
    puts 'Linting generated files ...'
    raise NO_ESLINT unless system('eslint --fix locations-data.js')
  end

  # Move the files to their correct locations
  task move_locations_files: :environment do
    puts 'Moving locations files ...'
    File.rename('locations-data.js', 'app/javascript/data/locations-data.js')
    File.rename('locations-data.rb', 'app/models/locations_table.rb')
  end

  desc 'SPARQL-describe the given URI'
  task :describe, [:uri] => [:environment] do |_t, args|
    uri = args[:uri]
    query = "describe <#{uri}>"

    squery = "#{ENV['FUSEKI'] || '/home/ian/dev/java/jena-fuseki'}/bin/s-query"
    server = ENV['SERVER'] || 'http://lr-data-dev-c.epimorphics.net/landregistry/query'

    puts 'Running SPARQL query ...'
    system "#{squery} --server='#{server}' '#{query}'"
  end
end
