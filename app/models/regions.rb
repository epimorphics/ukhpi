# frozen_string_literal: true

require 'regions-table'

# Encapsulates the regions that observations can apply to
class Regions
  extend RegionsTable

  Struct.new('LocationSearchType', :label, :rdf_types)

  # rubocop:disable Layout/IndentArray
  LOCATION_SEARCH_TYPES = {
    country: Struct::LocationSearchType.new('Country', [
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion'
    ]),
    local_authority: Struct::LocationSearchType.new('Local authority', [
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough',
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/District',
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/LondonBorough',
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/MetropolitanDistrict',
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/UnitaryAuthority'
    ]),
    england_region: Struct::LocationSearchType.new('Region (England only)', [
      'http://landregistry.data.gov.uk/def/ukhpi/Region'
    ]),
    england_county: Struct::LocationSearchType.new('County (England only)', [
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/County'
    ])
  }.freeze

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

  def self.region_label(uri)
    (loc = locations[uri]) && loc.label
  end

  def self.lookup_gss(gss)
    locations.values.find { |loc| loc.is_gss?(gss) }
  end

  def self.each_location(&block)
    locations.values.each(&block)
  end

  # @return A list of options for the types of location search, in a form suitable
  # for building a select element in the UI
  def self.location_search_options
    LOCATION_SEARCH_TYPES.map do |key, search_option|
      [search_option.label, key]
    end
  end
end
