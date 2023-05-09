# frozen_string_literal: true

# User selections for the task of comparing one or more locations with
# each other
class UserCompareSelections
  include UserChoices
  include UserLanguage

  DEFAULT_INDICATOR = 'hpi'
  DEFAULT_STATISTIC = 'all'
  DEFAULT_LOCATIONS = %w[K02000001 W92000004 S92000003 E92000001 N92000001].freeze

  USER_PARAMS_MODEL = {
    'location' => Struct::UserParam.new(DEFAULT_LOCATIONS, true, nil),
    'location-term' => Struct::UserParam.new('', false, nil),
    'from' => Struct::UserParam.new(Time.zone.today.prev_year, false, nil),
    'to' => Struct::UserParam.new(Time.zone.today, false, nil),
    'st' => Struct::UserParam.new(DEFAULT_STATISTIC, false, nil),
    'in' => Struct::UserParam.new(DEFAULT_INDICATOR, false, nil),
    'lang' => Struct::UserParam.new(:en, false, nil),

    # used by selections update form
    'form-action' => Struct::UserParam.new(nil, false, nil),
    'utf8' => Struct::UserParam.new(nil, false, nil)
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

  def selected_locations
    param_or_default('location').map do |location_id|
      location = Locations.lookup_gss(location_id)
      location ||
        raise(ActionController::BadRequest, "Location code not understood: #{location_id}")
    end
  end

  def from_date
    parse_date(param_or_default('from'))
  end

  def to_date
    parse_date(param_or_default('to'))
  end

  def selected_statistic
    param_or_default('st')
  end

  def selected_statistics
    [selected_statistic]
  end

  def selected_indicator
    param_or_default('in')
  end

  def selected_indicators
    [selected_indicator]
  end

  def search_term
    @search_term ||= params[:'location-term']
  end

  def search?
    params[:'form-action'] == 'search'
  end

  delegate :to_h, to: :params

  def as_json # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    {
      from: { date: from_date }.to_json,
      to: { date: to_date }.to_json,
      indicators: ukhpi_data_cube.indicators.map do |indicator|
        indicator.to_h(self)
      end.to_json,
      st: selected_statistic.to_json,
      in: selected_indicator.to_json,
      locations: selected_locations.map(&:to_h).to_json,
      themes: ukhpi_data_cube.themes.map do |_slug, theme|
        theme.to_h(self)
      end.to_json
    }
  end

  private

  def ukhpi_data_cube
    @ukhpi_data_cube ||= UkhpiDataCube.new
  end
end
