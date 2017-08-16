# frozen_string_literal: true

# Encapsulates the user's articulated preferences for filtering and displaying
# House Price Index data
class UserPreferences
  DEFAULT_ASPECT_INDICATORS =
    %w[housePriceIndex averagePrice percentageChange percentageAnnualChange].freeze
  DEFAULT_ASPECT_CATEGORIES = [''].freeze
  DEFAULT_COMMON_STATS = %w[salesVolume].freeze

  DEFAULTS = {
    from: Date.today.prev_year,
    to: Date.today,
    region: Constants::DEFAULT_LOCATION,
    ai: DEFAULT_ASPECT_INDICATORS,
    ac: DEFAULT_ASPECT_CATEGORIES,
    cs: DEFAULT_COMMON_STATS
  }.freeze

  include ParameterValidations

  def initialize(params)
    @params = params[:__safe_params] || scrub_params(params)
    @params.freeze
  end

  def aspect_indicators
    value_of(:ai)
  end

  def aspect_categories
    value_of(:ac)
  end

  def common_stats
    value_of(:cs)
  end

  def method_missing(key, *_args) # rubocop:disable Style/MethodMissing
    WHITELIST.include?(key.to_sym) ? value_of(key.to_sym) : nil
  end

  def respond_to_missing?(method, _args = nil)
    WHITELIST.include?(method.to_sym)
  end

  def with(p, v)
    UserPreferences.new(__safe_params: @params.merge(p => v))
  end

  def as_search_string
    @params
      .map { |k, v| encode_as_search_string(k, v) }
      .sort
      .join('&')
  end

  def to_hash
    @params
  end

  def prefs
    self
  end

  def summary
    templates = {
      region: '%s',
      from: 'from %s',
      to: 'to %s'
    }

    apply_templates(templates, @params).join(' ')
  end

  private

  def value_of(param)
    @params[param] || DEFAULTS[param]
  end

  def encode_as_search_string(k, v)
    v = v.map(&:to_s).join(',') if v.is_a?(Array)
    "#{URI.escape k.to_s}=#{URI.escape v.to_s}"
  end

  def apply_templates(templates, params)
    templates.map do |k, template|
      if (value = params[k])
        template % format_preference_value(value)
      end
    end .compact
  end

  def format_preference_value(value)
    if (r = Regions.lookup_region(value))
      r.label
    elsif value.is_a?(Date)
      value.strftime('%B %Y')
    else
      value.to_s
    end
  end
end
