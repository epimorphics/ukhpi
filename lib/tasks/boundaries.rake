require 'bundler/setup'
Bundler.require

require './app/models/regions-table'

BL_SOURCE = "./data/boundary-line/Data/"
COUNTY_SOURCE = "#{BL_SOURCE}GB/county_region.shp"
DISTRICT_SOURCE = "#{BL_SOURCE}GB/district_borough_unitary_region.shp"
EURO_REGION_SOURCE = "#{BL_SOURCE}GB/european_region_region.shp"
CEREMONIAL_SOURCE = "#{BL_SOURCE}Supplementary_Ceremonial/Boundary-line-ceremonial-counties.shp"

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

class RT
  include RegionsTable
end

namespace :ukhpi do
  desc "Check region names against index"
  task region_names_check: :environment do
    regions = RT.new
    index =composite_index
    puts "Index has #{index.size} keys"

    regions.location_names.each do |location|
      name = location[:label].upcase
      if index[name]
        print "."
        STDOUT.flush
      else
        puts "\nlocation[:label]"
      end
    end
  end
end
