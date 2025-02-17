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
  include UserSelectionValidations
  include UserLanguage

  DEFAULT_INDICATORS = %w[hpi avg pmc pac].freeze
  DEFAULT_STATISTICS = %w[all].freeze
  DEFAULT_NON_PT_INDICATORS = %w[salesVolume].freeze
  DEFAULT_REGION = 'http://landregistry.data.gov.uk/id/region/united-kingdom'
  DEFAULT_REGION_TYPE = 'country'
  DEFAULT_THEMES = %w[property_type volume].freeze
  DEFAULT_LANGUAGE = 'en'

  USER_PARAMS_MODEL = {
    'location' => Struct::UserParam.new(DEFAULT_REGION, false, nil),
    'location-type' => Struct::UserParam.new(DEFAULT_REGION_TYPE, false, nil),
    'location-term' => Struct::UserParam.new('', false, nil),
    'from' => Struct::UserParam.new(
      Time.zone.today.beginning_of_month.prev_year.prev_month, false, nil
    ),
    'to' => Struct::UserParam.new(Time.zone.today.beginning_of_month.prev_month, false, nil),
    'explain' => Struct::UserParam.new(false, false, nil),
    'st' => Struct::UserParam.new(DEFAULT_STATISTICS, true, nil),
    'in' => Struct::UserParam.new(DEFAULT_INDICATORS, true, nil),
    'thm' => Struct::UserParam.new(DEFAULT_THEMES, true, nil),
    'lang' => Struct::UserParam.new(DEFAULT_LANGUAGE, false, nil),

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

  def selected_statistics(options = {})
    if all?(options, %w[st in thm])
      UkhpiDataCube.new.statistics.map(&:slug)
    else
      param_or_default('st')
    end
  end

  def selected_indicators(options = {})
    if all?(options, %w[st in thm])
      UkhpiDataCube.new.indicators.map(&:slug)
    else
      param_or_default('in')
    end
  end

  def selected_themes
    param_or_default('thm')
  end

  def action
    params['form-action']
  end

  def clear_selected_location
    params['location'] = nil
  end

  def summary
    templates = {
      thm: '%s',
      st: '%s',
      in: '%s',
      location: '%s',
      from: 'from %s',
      to: 'to %s'
    }

    apply_templates(templates, @params).join(' ')
  end

  private

  def apply_templates(templates, params)
    templates.map do |k, template|
      if (value = params[k])
        template % format_summary_value(value)
      end
    end.compact
  end

  def format_summary_value(value)
    if (r = Locations.lookup_location(value))
      r.label
    elsif value.is_a?(Date)
      I18n.l(value, format: '%B %Y')
    elsif value.is_a?(Array)
      value.map(&method(:format_summary_value)).join(' ')
    else
      value.to_s
    end
  end

  # Return true if: `options[:all]` is `true`, and all of the params in
  # `check_params` have no value in the current `params`
  def all?(options, check_params)
    options[:all] &&
      check_params.map { |p| params[p] }.compact.empty?
  end
end
