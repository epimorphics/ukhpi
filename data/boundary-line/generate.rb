#!/usr/bin/ruby

# Generate simplified boundary lines for counties and regions
require 'bundler'
require 'json'
Bundler.require

TARGET_COUNTY_NAMES = "../county-names.txt"

COUNTY_SOURCE = "./Data/GB/county_region.shp"
DISTRICT_SOURCE = "./Data/GB/district_borough_unitary_region.shp"
EURO_REGION_SOURCE = "./Data/GB/european_region_region.shp"
CEREMONIAL_SOURCE = "./Data/Supplementary_Ceremonial/Boundary-line-ceremonial-counties.shp"

SIMPLIFICATION = 500

BNG_PROJECTION = RGeo::Cartesian.factory( proj4: '+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894 +units=m +no_defs' )
LATLONG_PROJECTION = RGeo::Cartesian.factory( proj4: "+proj=longlat +ellps=WGS84 +towgs84=0,0,0 +no_defs" )

MAX_AREA = 99999999

def as_keys( name )
  candidates = []

  name.upcase.split( " - ").each do |n|
    n = n.gsub( /\(B\)/, "" )

    candidates << n
    candidates << n.gsub( /County\Z/, "" )
    candidates << n.gsub( /\ACounty of/, "" )
    candidates << n.gsub( /The City Of/i, "" )
    candidates << n.gsub( /City Of/i, "" )
    candidates << n.gsub( /euro region/i, "" )
    candidates << n.gsub( /\&/, "AND" )
  end

  candidates.map( &:strip ).uniq
end

def create_index( filename, index = Hash.new )
  RGeo::Shapefile::Reader.open( filename ) do |file|
    file.each do |record|
      name = record.attributes["NAME"] || record.attributes["Name"]
      as_keys( name ).each do |key|
        index[key] = record
      end
    end
  end

  index
end

def composite_index
  create_index(
    CEREMONIAL_SOURCE,
    create_index(
      EURO_REGION_SOURCE,
      create_index(
        COUNTY_SOURCE,
        create_index( DISTRICT_SOURCE ) )))
end

def normalize_county_name( name )
  name
    .upcase
    .gsub( /RHONDDA CYNON TAFF/, "RHONDDA CYNON TAF")
    .gsub( /\AWREKIN\Z/, "TELFORD AND WREKIN")
end

def target_counties
  File
    .read( TARGET_COUNTY_NAMES )
    .split( "\n" )
    .map &method(:normalize_county_name)
end

def as_geo_record( name, index )
  index[name] || raise( "No data for '#{name}'")
end

def simplify_line( line )
  puts( "Starting simplify, #points = #{line.length}")
  xy = to_xy( line )
  simplified = SimplifyRb.simplify( xy, SIMPLIFICATION, true )
  puts( " .. done simplify, #points = #{simplified.length}")
  from_xy( simplified )
end

def to_xy( line )
  line.map {|p| {x: p[0].round(3), y: p[1].round(3)}}
end

def from_xy( line )
  line.map {|p| [p[:x], p[:y]]}
end

def as_geojson_feature( name, record )
  RGeo::GeoJSON::Feature.new( record.geometry, name, record.attributes )
end

def is_point?( p )
  p.is_a?( Array ) &&
  (p.length == 2 || p.length == 4) &&
  (p[0].is_a? Numeric) &&
  (p[1].is_a? Numeric)
end

def is_line?( a )
  a.is_a?( Array ) &&
  a.all? {|v| is_point?( v )}
end

def simplify_lines( a )
  a.map do |a_value|
    if is_line?( a_value )
      simplify_line( a_value )
    else
      simplify_lines( a_value )
    end
  end
end

def point_to_lat_long( point )
  bng_point = BNG_PROJECTION.point( *point )
  lat_long_point = RGeo::Feature.cast( bng_point, type: RGeo::Feature::Point, factory: LATLONG_PROJECTION, project: true )
  [lat_long_point.x, lat_long_point.y]
end

def line_to_lat_long( a )
  a.map do |a_value|
    if is_point?( a_value )
      point_to_lat_long( a_value )
    else
      line_to_lat_long( a_value )
    end
  end
end

def load_json
  File.exist?( "fc.json" ) && JSON.load( File.open( "fc.json" ) )
end

def transform_coordinates( json, fn )
  j_features = json["features"]
  j_features.each do |feature|
    geometry = feature["geometry"]
    geometry["coordinates"] = fn.call( geometry["coordinates"] )
  end
end

json = load_json
if json
  puts "Loaded json"
else
  puts "Start indexing"
  index = composite_index

  puts "Done indexing, generating features"

  features = target_counties.map do |county_name|
    as_geojson_feature( county_name, as_geo_record( county_name, index ) )
  end

  puts "Sorting by reverse area"
  features.sort! do |f0, f1|
    (f1.property("HECTARES") || MAX_AREA) <=> (f0.property("HECTARES") || MAX_AREA)
  end

  puts "Done feature generation, generating collection"
  fc = RGeo::GeoJSON::FeatureCollection.new( features )

  puts "Done collecting"
  json = RGeo::GeoJSON.encode( fc )

  puts "Saving file fc.json"
  File.open( "fc.json", "w" ) {|f| f << JSON.generate( json )}
end


puts "Simplifying"
transform_coordinates( json, method( :simplify_lines ) )

puts "Converting to lat long"
transform_coordinates( json, method( :line_to_lat_long ) )

File.open( "fc_simple.json", "w" ) do |file|
  file << JSON.generate( json )
  file.flush
end

puts "Done."
