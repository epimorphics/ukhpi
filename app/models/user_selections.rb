# frozen_string_literal: true

# This class encapsulates the user input via the request params, and uses that
# to determine which UKHPI statistics should be selected from the store and
# subsequently displayed.
#
# This class also incorporates the notion of default selections, so that a
# standard set of statistics is presented if there is no information in the
# user parameters yet. This functionality combines the previous
# `models/UserPreferences` and `presenters/Aspects`
class UserSelections
  Struct.new('UserParam', :default_value, :'array?', :alias)

  DEFAULT_INDICATORS =
    %w[housePriceIndex averagePrice percentageChange
       percentageAnnualChange].freeze
  DEFAULT_PROPERTY_TYPES = [''].freeze
  DEFAULT_NON_PT_INDICATORS = %w[salesVolume].freeze
  DEFAULT_REGION = 'http://landregistry.data.gov.uk/id/region/united-kingdom'
  DEFAULT_REGION_TYPE = 'country'

  USER_PARAMS_MODEL = {
    'region' => Struct::UserParam.new(DEFAULT_REGION, false, nil),
    'location-type' => Struct::UserParam.new(DEFAULT_REGION_TYPE, false, nil),
    'from' => Struct::UserParam.new(Date.today.prev_year, false, nil),
    'to' => Struct::UserParam.new(Date.today, false, nil),
    'explain' => Struct::UserParam.new(false, false, nil),
    'pt' => Struct::UserParam.new(DEFAULT_PROPERTY_TYPES, true, nil),
    'in' => Struct::UserParam.new(DEFAULT_INDICATORS, true, nil),
    'np' => Struct::UserParam.new(DEFAULT_NON_PT_INDICATORS, true, nil),

    # legacy codes
    'ai' => Struct::UserParam.new(nil, true, 'in'),
    'ac' => Struct::UserParam.new(nil, true, 'pt')
  }.freeze

  PERMITTED = USER_PARAMS_MODEL
              .map { |k, v| v.array? ? { k => [] } : k }
              .freeze

  attr_reader :params

  def initialize(params)
    @params = params.permit(*PERMITTED)
  end

  def selected_region
    param_or_default('region')
  end

  def selected_region_type
    param_or_default('location-type')
  end

  def from_date
    param_or_default('from')
  end

  def to_date
    param_or_default('to')
  end

  def explain?
    param_or_default('explain') == 'true'
  end

  def property_types
    param_or_default('pt')
  end

  def indicators
    param_or_default('in')
  end

  def non_property_type_indicators
    param_or_default('np')
  end

  private

  # Return the param value for the given key, or if that is nil:
  # * return the value of the alias key if that has a value (legacy support)
  # * return the default value
  def param_or_default(key)
    return params[key] unless params[key].nil?
    if (alt_key = alternative_key(key)) && params[alt_key]
      return params[alt_key]
    end

    USER_PARAMS_MODEL[key].default_value
  end

  def alternative_key(k)
    USER_PARAMS_MODEL
      .find { |_key, value| value.alias == k }
      &.first
  end
end
