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
  include UserChoices

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

  def initialize(params)
    @params = params[:__safe_params] || params.permit(*PERMITTED)
  end

  def user_params_model
    USER_PARAMS_MODEL
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

  def clear_selected_location
    params['location'] = nil
  end
end
