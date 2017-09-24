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

  DEFAULT_INDICATORS = %w[hpi avg pmc pac].freeze
  DEFAULT_STATISTICS = %w[all vol].freeze
  DEFAULT_NON_PT_INDICATORS = %w[salesVolume].freeze
  DEFAULT_REGION = 'http://landregistry.data.gov.uk/id/region/united-kingdom'
  DEFAULT_REGION_TYPE = 'country'
  DEFAULT_THEMES = %w[property_type volume].freeze

  USER_PARAMS_MODEL = {
    'location' => Struct::UserParam.new(DEFAULT_REGION, false, nil),
    'location-type' => Struct::UserParam.new(DEFAULT_REGION_TYPE, false, nil),
    'location-term' => Struct::UserParam.new('', false, nil),
    'from' => Struct::UserParam.new(Date.today.prev_year, false, nil),
    'to' => Struct::UserParam.new(Date.today, false, nil),
    'explain' => Struct::UserParam.new(false, false, nil),
    'st' => Struct::UserParam.new(DEFAULT_STATISTICS, true, nil),
    'in' => Struct::UserParam.new(DEFAULT_INDICATORS, true, nil),
    'thm' => Struct::UserParam.new(DEFAULT_THEMES, true, nil),

    # used by selections update form
    'form-action' => Struct::UserParam.new(nil, false, nil),
    'utf8' => Struct::UserParam.new(nil, false, nil),

    # legacy codes
    'ai' => Struct::UserParam.new(nil, true, 'in'),
    'ac' => Struct::UserParam.new(nil, true, 'st'),
    'region' => Struct::UserParam.new(nil, false, 'location'),
    'region-selection' => Struct::UserParam.new(nil, false, 'location-term')
  }.freeze

  PERMITTED = USER_PARAMS_MODEL
              .map { |k, v| v.array? ? { k => [] } : k }
              .freeze

  attr_reader :params

  def initialize(params)
    @params = params[:__safe_params] || params.permit(*PERMITTED)
  end

  def selected_location
    param_or_default('location')
  end

  def location_search_type
    param_or_default('location-type')
  end

  def location_search_term
    param_or_default('location-term')
  end

  def from_date
    parse_date(param_or_default('from'))
  end

  def to_date
    parse_date(param_or_default('to'))
  end

  def explain?
    param_or_default('explain') == 'true'
  end

  def selected_statistics
    param_or_default('st')
  end

  def selected_indicators
    param_or_default('in')
  end

  def selected_themes
    param_or_default('thm')
  end

  def to_h
    params.to_h
  end

  def action
    params['form-action']
  end

  # @return A new UserSelections object in which the parameter `param` has
  # the value `val` instead of the current value. Does not change this
  # UserSelections object
  def with(param, val)
    UserSelections.new(__safe_params: @params.merge(param => val))
  end

  # @return A new UserSelections object in which the parameter `param` has
  # been removed. Does not change this UserSelections object
  def without(param)
    new_params = @params.dup
    new_params.delete(param)
    UserSelections.new(__safe_params: new_params)
  end

  def clear_selected_location
    params['location'] = nil
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

  def parse_date(date)
    date.is_a?(String) ? Date.parse(date) : date
  end
end
