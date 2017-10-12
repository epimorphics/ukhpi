# frozen-string-literal: true

# User selections for the task of comparing one or more locations with
# each other
class UserCompareSelections
  include UserChoices

  DEFAULT_INDICATOR = 'hpi'
  DEFAULT_STATISTIC = 'all'
  DEFAULT_LOCATIONS = %w[K02000001 S92000003].freeze

  USER_PARAMS_MODEL = {
    'location' => Struct::UserParam.new(DEFAULT_LOCATIONS, true, nil),
    'from' => Struct::UserParam.new(Date.today.prev_year, false, nil),
    'to' => Struct::UserParam.new(Date.today, false, nil),
    'st' => Struct::UserParam.new(DEFAULT_STATISTIC, false, nil),
    'in' => Struct::UserParam.new(DEFAULT_INDICATOR, false, nil),

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
    param_or_default('location')
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

  def selected_indicator
    param_or_default('in')
  end

  def to_h
    params.to_h
  end
end
