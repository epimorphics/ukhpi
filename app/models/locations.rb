# frozen_string_literal: true

require_dependency 'regions-table'

# Encapsulates the set of all of the locations that UKHPI observations can apply to
class Locations
  extend LocationsTable

  Struct.new('LocationSearchType', :label, :rdf_types)

  # rubocop:disable Layout/IndentArray
  LOCATION_SEARCH_TYPES = {
    'country' => Struct::LocationSearchType.new('Country', [
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion'
    ]),
    'local_authority' => Struct::LocationSearchType.new('Local authority', [
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough',
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/District',
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/LondonBorough',
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/MetropolitanDistrict',
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/UnitaryAuthority'
    ]),
    'england_region' => Struct::LocationSearchType.new('Region (England only)', [
      'http://landregistry.data.gov.uk/def/ukhpi/Region'
    ]),
    'england_county' => Struct::LocationSearchType.new('County (England only)', [
      'http://data.ordnancesurvey.co.uk/ontology/admingeo/County'
    ])
  }.freeze

  # @return The Location with the given URI, if it exists
  def self.lookup_location(uri)
    locations[uri]
  end

  # @return The label for the reqion with the given URI, or nil
  def self.location_label(uri)
    (loc = locations[uri]) && loc.label
  end

  # @return A list of options for the types of location search, in a form suitable
  # for building a select element in the UI
  def self.location_search_options
    LOCATION_SEARCH_TYPES.map do |key, search_option|
      [search_option.label, key]
    end
  end

  # Return an array of the locations whose name matches the given term
  # @param term A string to match against the name
  # @param location_type A key to the LOCATION_SEARCH_TYPES table denoting the
  # kind of location to search for
  def self.search_location(term, location_type)
    types = LOCATION_SEARCH_TYPES[location_type].rdf_types

    locations.values.select do |loc|
      loc.matches_name?(term, types)
    end
  end

  # legacy watermark

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

  def self.lookup_gss(gss)
    locations.values.find { |loc| loc.is_gss?(gss) }
  end

  def self.each_location(&block)
    locations.values.each(&block)
  end
end
