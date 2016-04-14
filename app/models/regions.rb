# Encapsulates the regions that observations can apply to
class Regions
  include RegionsTable

  def self.parse_region( region_name, params )
    rtype = self.parse_region_type( params[:rt] )
    locations.find do |uri, loc|
      loc.matches_name?( region_name, rtype )
    end
  end

  def self.parse_region_type( region_type )
    types.include?( region_type ) || raise "Not a valid region type: #{region_type}"
  end
end
