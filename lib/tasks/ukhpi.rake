require 'set'
require 'json'
require 'byebug'
require 'csv'

# Helper classes
class LocationRecord
  def initialize( json )
    @json = json
  end

  def value_of( json )
    (json && json["value"]) || json
  end

  def uri
    value_of( @json["refRegion"] )
  end

  def label
    value_of @json["label"]
  end

  def lang
    @json["label"]["xml:lang"]
  end

  def parent
    value_of @json["parent"]
  end

  def same
    value_of @json["same"]
  end

  def type
    value_of @json["type"]
  end
end

class Location
  attr_reader :uri, :labels, :parent, :gss

  def initialize( lr )
    @uri = lr.uri
    @parent = lr.parent
    @labels = {}
    @types = []

    update_from( lr )
  end

  def update_from( lr )
    add_type( lr.type ) if lr.type
    add_label( lr )

    if lr.same
      @same = lr.same
      if @same =~ /(E\d+)$/
        @gss = $1
      end
    end
  end

  def add_type( t )
    @types << t
  end

  def add_label( lr )
    @labels[lr.lang.to_sym] = lr.label
  end

  def preferred_type
    @types.find {|t| t =~/admingeo/}
  end

  def to_ruby
    "Region.new( #{uri.inspect}, #{@labels.inspect}, #{preferred_type.inspect}, #{parent.inspect}, \"#{gss}\" )"
  end

  def to_json
    "{#{json_attributes}}"
  end

  def json_attributes
    [
      "uri: \"#{uri}\"",
      "gss: \"#{gss}\"",
      "parent: \"#{parent}\"",
      "type: \"#{preferred_type}\"",
    ].join( ", " )
  end
end

def write_regions_files( locations, all_types )
  location_names = []
  gss_index = Hash.new

  locations.each do |uri,loc|
    loc.labels.each do |lang,txt|
      location_names << {value: loc.uri, label: txt, lang: lang}
    end

    # properties[:children] = properties[:children].to_a.sort
    gss_index[loc.gss] = loc.uri if loc.gss
  end

  location_names.sort! {|l0,l1| l0[:label] <=> l1[:label]}

  puts "Generating region files ... "
  # JavaScript module output
  open( "regions-table.js", "w") do |file|
    file << "define( [], function() {\n"
    file << "\"use strict\";\n"
    file << "  var locationNames = #{location_names.to_json};\n"
    file << "  var types = #{all_types.to_a.sort.to_json};\n"
    file << "  var locations = {\n"
    sep = "  "
    locations.each do |uri,loc|
      file << "#{sep}\"#{uri}\": #{loc.to_json}"
      sep = ",\n  "
    end
    file << "\n};\n"
    file << "  var gssIndex = #{gss_index.to_json};\n"
    file << "  return {names: locationNames, types: types, locations: locations, gssIndex: gssIndex };\n"
    file << "});\n"
  end

  # Ruby module output
  open( "regions-table.rb", "w") do |file|
    file << "module RegionsTable\n"
    file << "  def location_names\n"
    file << "    #{location_names.inspect}\n"
    file << "  end\n"
    file << "  def types\n"
    file << "    #{all_types.to_a.sort.inspect}\n"
    file << "  end\n"
    file << "  def locations\n"
    file << "    {\n"
    locations.each do |uri,loc|
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

namespace :ukhpi do
  desc "Generate the regions files by SPARQL query"
  task regions_sparql: [:regions_query, :regions_generate, :move_region_files]

  desc "run the SPARQL query to generate the region results"
  task regions_query: :environment do
    rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    qb="http://purl.org/linked-data/cube#"
    hpi="http://landregistry.data.gov.uk/def/ukhpi/"
    rdfs="http://www.w3.org/2000/01/rdf-schema#"
    sr="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
    owl="http://www.w3.org/2002/07/owl#"

    query="select distinct ?refRegion ?label ?type ?parent ?same {
      GRAPH <http://landregistry.data.gov.uk/UKHPI-2014-01> {
        ?obs a <#{qb}Observation> ;
          <#{hpi}refRegion> ?refRegion.
        ?refRegion <#{rdfs}label> ?label.
        ?refRegion <#{rdf}type> ?type.
        optional {?refRegion <#{sr}within> ?parent.}
        optional {?refRegion <#{owl}sameAs> ?same}
      }
    }"

    squery=(ENV["FUSEKI"] || "/home/ian/dev/java/jena-fuseki") + "/bin/s-query"
    server=ENV["SERVER"] || "http://lr-data-dev-c.epimorphics.net/landregistry/query"

    puts "Running SPARQL query ..."
    system "#{squery} --server='#{server}' '#{query}' > query-results.json"

  end

  desc "Generate the regions modules in JavaScript and Ruby"
  task regions_generate: :environment do
    puts "Loading query results ..."
    sresults = JSON.parse( IO.read( 'query-results.json' ) )
    locations = Hash.new
    all_types = Set.new

    sresults["results"]["bindings"].each do |result|
      lr = LocationRecord.new( result )
      loc = locations[lr.uri]
      all_types << lr.type

      if loc
        loc.update_from( lr )
      else
        locations[lr.uri] = Location.new( lr )
      end
    end

    write_regions_files( locations, all_types )
  end

  desc "Move the files to their correct locations"
  task move_region_files: :environment do
    puts "Moving region files ..."
    File.rename( "regions-table.js", "app/assets/javascripts/regions-table.js" )
    File.rename( "regions-table.rb", "app/models/regions-table.rb" )
  end
end
