require 'bundler/setup'
Bundler.require(:development)

require './app/models/regions-table'
require 'find'
require 'rake'

BL_SOURCE = "./data/boundary-line/Data/"
COUNTY_SOURCE = "#{BL_SOURCE}GB/county_region.shp"
DISTRICT_SOURCE = "#{BL_SOURCE}GB/district_borough_unitary_region.shp"
EURO_REGION_SOURCE = "#{BL_SOURCE}GB/european_region_region.shp"
CEREMONIAL_SOURCE = "#{BL_SOURCE}Supplementary_Ceremonial/Boundary-line-ceremonial-counties.shp"
SCOTLAND_WALES_SOURCE = "#{BL_SOURCE}/GB/scotland_and_wales_const_region.shp"
IRELAND_COUNTIES_SOURCE = "#{BL_SOURCE}/UK/OSNI_Open_Data_Largescale_Boundaries__County_Boundaries.shp"
IRELAND_DISTRICTS_SOURCE = "#{BL_SOURCE}/UK/OSNI_Open_Data_Largescale_Boundaries__Local_Government_Districts_2012.shp"
IRELAND_SOURCE = "#{BL_SOURCE}/UK/OSNI_Open_Data_Largescale_Boundaries__NI_Outline.shp"

ONS_REGIONS  = "#{BL_SOURCE}/ONS_regions/RGN_DEC_2015_EN_BGC.shp"
ONS_DISTRICTS = "#{BL_SOURCE}/ONS_districts/LAD_DEC_2015_GB_BGC.shp"
ONS_COUNTRIES = "#{BL_SOURCE}/ONS_countries/CTRY_DEC_2015_GB_BGC.shp"

SOURCES = [{source: COUNTY_SOURCE, type: "county", projection: :bng},
           {source: DISTRICT_SOURCE, type: "district", projection: :bng},
           {source: EURO_REGION_SOURCE, type: "region", projection: :bng},
           # {source: CEREMONIAL_SOURCE,type: "county", projection: :bng},
           {source: IRELAND_COUNTIES_SOURCE, type: "county", projection: :bng},
           {source: IRELAND_DISTRICTS_SOURCE,type: "district", projection: :bng},
           {source: ONS_REGIONS, type: "region", projection: :bng},
           {source: ONS_DISTRICTS, type: "district", projection: :bng},
           {source: ONS_COUNTRIES,type: "country", projection: :bng}
           #{source: IRELAND_SOURCE,type: "country", projection: :wgs84}
          ]

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
    candidates << n.gsub( /outline of/i, "" )
  end

  candidates.map( &:strip ).uniq
end

def create_index( options, index = Hash.new )
  filename = options[:source]
  puts "Indexing #{filename}"
  RGeo::Shapefile::Reader.open( filename ) do |file|
    file.each do |record|
      attribs = record.attributes

      gss_or_name = attribs["CODE"] || attribs["Code"] ||
                    attribs["LGDCode"] ||
                    attribs["CTRY15CD"] || attribs["LAD15CD"] || attribs["RGN15CD"] ||
                    attribs["NAME"] || attribs["Name"] || attribs["CountyName"] ||
                    attribs["NAME_LOCAL"]

      if gss_or_name
        attribs["ukhpiID"] = gss_or_name
        attribs["ukhpiType"] = options[:type]
        attribs["ukhpiProjection"] = options[:projection]

        as_keys( gss_or_name ).each do |key|
          index[key] = record
        end
      else
        puts "No code or name for: #{record.attributes.inspect}"
      end
    end
  end

  index
end

def composite_index( sources )
  sources.inject( Hash.new ) do |acc, source|
    create_index( source, acc )
  end
end

def as_geo_record( location, index )
  index[location.gss] || index[location.label.upcase]
end

def simplify_line( line )
  if is_ring?( line )
    simplify_ring( line )
  else
    simplify_non_ring_line( line )
  end
end

def is_ring?( line )
  f = line.first
  l = line.last

  !line.empty? && (f[0] == l[0]) && (f[1] == l[1])
end

def simplify_ring( ring )
  return ring if ring.length <= 3

  group_length = [250, (ring.length / 3).to_i].min
  segments = []
  ring.in_groups_of( group_length, false ) {|g| segments << g}

  # check for short last group
  if segments.last.length < 8
    g0 = segments.pop
    g1 = segments.pop
    segments.push( g1 + g0 )
  end

  puts( "ring of length #{ring.length} processing as #{segments.length} segments of length #{segments.first.length}")
  simplify_lines( segments ).inject &:+
end

def simplify_non_ring_line( line )
  puts( "Starting simplify non-ring, no. points = #{line.length}")
  xy = to_xy( line )
  l = SimplifyRb.simplify( xy, SIMPLIFICATION, true )

  puts( " .. done simplify, no. points = #{l.length}")

  from_xy( l )
end

def to_xy( line )
  line.map {|p| {x: p[0], y: p[1]}}
end

def from_xy( line )
  line.map {|p| [p[:x], p[:y]]}
end

def as_geojson_feature( name, record )
  if record.attributes["ukhpiProjection"].to_sym == :wgs84
    bng_geometry = RGeo::Feature.cast( record.geometry, factory: BNG_PROJECTION, project: true )
    RGeo::GeoJSON::Feature.new( bng_geometry, name, record.attributes )
  else
    RGeo::GeoJSON::Feature.new( record.geometry, name, record.attributes )
  end
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

def point_to_bng( point )
  ll_point = LATLONG_PROJECTION.point( *point )
  bng_point = RGeo::Feature.cast( ll_point, type: RGeo::Feature::Point, factory: BNG_PROJECTION, project: true )
  [bng_point.x, bng_point.y]
end

def line_to_bng( a )
  a.map do |a_value|
    if is_point?( a_value )
      point_to_bng( a_value )
    else
      line_to_bng( a_value )
    end
  end
end

def load_index
  puts "Creating index"
  composite_index( SOURCES )
end

def transform_coordinates( json, fn )
  j_features = json["features"]
  j_features.each do |feature|
    geometry = feature["geometry"]
    geometry["coordinates"] = fn.call( geometry["coordinates"] )
  end
end


namespace :ukhpi do
  desc "Generate the features.json file"
  task generate_features: :environment do
    index = load_index
    puts "Done indexing, generating features"

    features = []
    Regions.each_location do |location|
      geo_record = as_geo_record( location, index )
      if geo_record
        features << as_geojson_feature( location.label, geo_record )
      else
        puts "No geo_record for #{location.label}"
      end
    end
    features << as_geojson_feature( "Northern Ireland", index["NORTHERN IRELAND"])

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

  desc "Simplify the raw features to smooth the outlines of the polygons. Generates fc.json unless it exists"
  task simplify_features: :environment do
    unless File.exist?( "fc.json" )
      Rake::Task["ukhpi:generate_features"].invoke
    end

    json = JSON.load( File.open( "fc.json" ) )

    puts "Simplifying"
    transform_coordinates( json, method( :simplify_lines ) )

    puts "Converting to lat long"
    transform_coordinates( json, method( :line_to_lat_long ) )

    Oj.default_options = {mode: :strict, float_precision: 6}
    File.open( "fc_simple.json", "w" ) do |file|
      file << Oj.dump( json )
      file.flush
    end
  end

  desc "Check region names against index"
  task region_names_check: :environment do
    index = load_index

    Regions.each_location do |location|
      if index[location.gss] || index[location.label.upcase]
        print "."
        STDOUT.flush
      else
        puts "\n#{location.label} - #{location.gss}"
      end
    end
  end

  desc "Produce attributes for all shape files"
  task shape_file_attribs: :environment do
    shape_files = []
    Find.find( "./data/boundary-line" ) do |file|
      shape_files << file if file =~ /.*\.shp$/
    end
    shape_files.each do |sf|
      puts "Creating attributes for #{sf}"
      attrib_file_name = sf.gsub( ".shp", ".attributes" )

      if File.exist?( attrib_file_name )
        puts " ... already exists"
      else
        File.open( attrib_file_name, "w" ) do |af|
          RGeo::Shapefile::Reader.open( sf ) do |file|
            file.each do |record|
              attribs = record.attributes
              af << attribs.inspect << "\n"
            end
          end
        end
      end
    end
  end

  desc "Create a background shapefile for the whole of the UK"
  task uk_shapefile: :environment do
    unless File.exist?( "uk.geojson" )
      puts "Reminder: download GBR_adm0.shp and export to uk.geojson with QGIS"
      abort "No input file"
    end

    json = JSON.load( File.new( "uk.geojson"))

    puts "Converting uk.geojson to BNG"
    transform_coordinates( json, method( :line_to_bng ) )

    puts "Simplifying"
    transform_coordinates( json, method( :simplify_lines ) )

    puts "Converting to lat long"
    transform_coordinates( json, method( :line_to_lat_long ) )

    Oj.default_options = {mode: :strict, float_precision: 6}
    File.open( "uk.json", "w" ) do |file|
      file << Oj.dump( json )
      file.flush
    end
  end
end
