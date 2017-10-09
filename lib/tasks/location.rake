# frozen_string_literal: true

require 'set'
require 'json'
require 'csv'

# Helper classes

# Value class encapsulating a JSON location record
class LocationRecord
  def initialize(json)
    @json = json
  end

  def value_of(json)
    (json && json['value']) || json
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
end

# Encapsulates a particular location or region
class Location
  attr_reader :uri, :labels, :container, :container2, :container3, :gss

  def initialize(lr)
    @uri = lr.uri
    @container = lr.container
    @container2 = lr.container2
    @container3 = lr.container3
    @labels = {}
    @types = []

    update_from(lr)
  end

  def update_from(lr)
    add_type(lr.type) if lr.type
    add_label(lr)

    return unless lr.same

    @same = lr.same
    match = @same.match(/([A-Z]\d+)$/)
    @gss = match[1] if match
  end

  def add_type(t)
    @types << t
  end

  def add_label(lr)
    @labels[lr.lang.to_sym] = lr.label
  end

  def preferred_type
    admin_geo_type(@types)
      .reject { |t| t =~ %r{/Borough} }
      .first
  end

  def admin_geo_type(types)
    types.select do |t|
      t =~ /admingeo/
    end .uniq
  end

  def to_ruby
    'Region.new(' \
      "#{uri.inspect}, " \
      "#{@labels.inspect}, " \
      "#{preferred_type.inspect}, " \
      "#{container.inspect}, " \
      "\"#{gss}\")"
  end

  def to_json
    "{#{json_attributes}}"
  end

  def json_attributes
    [
      "uri: \"#{uri}\"",
      "gss: \"#{gss}\"",
      "container: \"#{container}\"",
      "container2: \"#{container2}\"",
      "container3: \"#{container3}\"",
      "type: \"#{preferred_type}\""
    ].join(', ')
  end
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def write_regions_files(locations, all_types)
  location_names = []
  gss_index = {}

  locations.each do |_uri, loc|
    loc.labels.each do |lang, txt|
      location_names << { value: loc.uri, label: txt, lang: lang } unless txt.empty?
    end

    # properties[:children] = properties[:children].to_a.sort
    gss_index[loc.gss] = loc.uri if loc.gss
  end

  location_names.sort! { |l0, l1| l0[:label] <=> l1[:label] }

  puts 'Generating region files ... '
  # JavaScript module output
  open('regions-table.js', 'w') do |file|
    file << "modulejs.define(\"regions-table\", [], function() {\n"
    file << "\"use strict\";\n"
    file << "  var locationNames = #{location_names.to_json};\n"
    file << "  var types = #{all_types.to_a.sort.to_json};\n"
    file << "  var locations = {\n"
    sep = '  '
    locations.each do |uri, loc|
      file << "#{sep}\"#{uri}\": #{loc.to_json}"
      sep = ",\n  "
    end
    file << "\n};\n"
    file << "  var gssIndex = #{gss_index.to_json};\n"
    file << '  return {names: locationNames, types: types, ' \
            "locations: locations, gssIndex: gssIndex };\n"
    file << "});\n"
  end

  # Ruby module output
  open('regions-table.rb', 'w') do |file|
    file << "# rubocop:disable all\n"
    file << "module RegionsTable\n"
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

# rubocop:disable Metrics/BlockLength
namespace :ukhpi do
  desc 'Generate the regions files by SPARQL query'
  task regions_sparql: %i[regions_query regions_generate move_region_files]

  # run the SPARQL query to generate the region results
  task regions_query: :environment do
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

    squery = (ENV['FUSEKI'] || '/home/ian/dev/java/jena-fuseki') + '/bin/s-query'
    server = ENV['SERVER'] || 'http://landregistry.data.gov.uk/landregistry/query'

    puts "Running SPARQL query against server #{server}..."
    puts '(to change the destination SPARQL endpoint, set the $SERVER env variable)'
    system "#{squery} --server='#{server}' '#{query}' > query-results.json"
  end

  # Generate the regions modules in JavaScript and Ruby
  task regions_generate: :environment do
    puts 'Loading query results ...'
    sresults = JSON.parse(IO.read('query-results.json'))
    locations = {}
    all_types = Set.new

    sresults['results']['bindings'].each do |result|
      lr = LocationRecord.new(result)
      loc = locations[lr.uri]
      all_types << lr.type

      if loc
        loc.update_from(lr)
      else
        locations[lr.uri] = Location.new(lr)
      end
    end

    write_regions_files(locations, all_types)
  end

  # Move the files to their correct locations
  task move_region_files: :environment do
    puts 'Moving region files ...'
    File.rename('regions-table.js', 'app/assets/javascripts/regions-table.js')
    File.rename('regions-table.rb', 'app/models/regions-table.rb')
  end

  desc 'SPARQL-describe the given URI'
  task :describe, [:uri] => [:environment] do |_t, args|
    uri = args[:uri]
    query = "describe <#{uri}>"

    squery = (ENV['FUSEKI'] || '/home/ian/dev/java/jena-fuseki') + '/bin/s-query'
    server = ENV['SERVER'] || 'http://lr-data-dev-c.epimorphics.net/landregistry/query'

    puts 'Running SPARQL query ...'
    system "#{squery} --server='#{server}' '#{query}'"
  end
end
