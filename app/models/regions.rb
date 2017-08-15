# frozen_string_literal: true

require 'regions-table'

# Encapsulates the regions that observations can apply to
class Regions
  extend RegionsTable

  def self.match(region_name, params)
    rtype = validate_region_type(params[:rt])
    locations.select do |_uri, loc|
      loc.matches_name?(region_name, rtype)
    end
  end

  def self.validate_region_type(region_type)
    !region_type ||
      types.include?(region_type) ||
      raise(ArgumentError, "Not a valid region type: #{region_type}")
    region_type
  end

  def self.lookup_region(uri)
    locations[uri]
  end

  def self.lookup_gss(gss)
    locations.values.find { |loc| loc.is_gss?(gss) }
  end

  def self.each_location(&block)
    locations.values.each(&block)
  end
end
