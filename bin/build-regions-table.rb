require 'set'
require 'json'

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
  def initialize( lr )
    @uri = lr.uri
    @parent = lr.parent
    @label = {}
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
    @types << t unless
  end

  def add_label( lr )
    @label[lr.lang] = lr.label
  end
end

sresults = JSON.parse( IO.read( 'query-results.json' ) )
locations = Hash.new

sresults["results"]["bindings"].each do |result|
  lr = LocationRecord.new( result )
  loc = locations[lr.uri]

  if loc
    loc.update_from( lr )
  else
    locations[lr.uri] = Location.new( lr )
  end
end

location_names = []
gss_index = Hash.new

locations.each do |loc|
  location_names << {value: uri, label: properties[:label]}
  # properties[:children] = properties[:children].to_a.sort
  properties[:types] = properties[:types].to_a.sort
  gss_index[properties[:gss]] = uri if properties[:gss]
end

location_names.sort! {|l0,l1| l0[:label] <=> l1[:label]}

puts all_types.to_a.sort

puts "var HpiLocations = function() {"
puts "var locationNames = #{location_names.to_json};"
puts "var locations = #{locations.to_json};"
puts "var gssIndex = #{gss_index.to_json};"
puts <<END
var regionNameIndex = {
  "Wales Euro Region":                      "http://landregistry.data.gov.uk/id/region/wales",
  "South West Euro Region":                 "http://landregistry.data.gov.uk/id/region/south-west",
  "South East Euro Region":                 "http://landregistry.data.gov.uk/id/region/south-east",
  "London Euro Region":                     "http://landregistry.data.gov.uk/id/region/london",
  "Eastern Euro Region":                    "http://landregistry.data.gov.uk/id/region/east",
  "East Midlands Euro Region":              "http://landregistry.data.gov.uk/id/region/east-midlands",
  "West Midlands Euro Region":              "http://landregistry.data.gov.uk/id/region/west-midlands-region",
  "North West Euro Region":                 "http://landregistry.data.gov.uk/id/region/north-west",
  "Yorkshire and the Humber Euro Region":   "http://landregistry.data.gov.uk/id/region/yorks-and-humber",
  "North East Euro Region":                 "http://landregistry.data.gov.uk/id/region/north-east"
};
END
puts "return {locationNames: locationNames, locations: locations, gssIndex: gssIndex, regionNameIndex: regionNameIndex };"
puts "}();"
