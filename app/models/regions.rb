# Encapsulates the regions that observations can apply to

require "regions-table"

class Regions
  extend RegionsTable

  def self.match( region_name, params )
    rtype = self.validate_region_type( params[:rt] )
    locations.select do |uri, loc|
      loc.matches_name?( region_name, rtype )
    end
  end

  def self.validate_region_type( region_type )
    !region_type || types.include?( region_type ) || raise( ArgumentError, "Not a valid region type: #{region_type}" )
    region_type
  end

  def self.lookup_region( uri )
    locations[uri]
  end

  def self.lookup_gss( gss )
    locations.values.find {|loc| loc.is_gss?( gss )}
  end

  def self.each_location( &block )
    locations.values.each( &block )
  end
end
