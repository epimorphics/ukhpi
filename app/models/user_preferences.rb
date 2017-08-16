# frozen_string_literal: true

# Encapsulates the user's articulated preferences for filtering and displaying
# House Price Index data
# rubocop:disable Metrics/ClassLength
class UserPreferences
  DEFAULT_ASPECT_INDICATORS =
    %w[housePriceIndex averagePrice percentageChange percentageAnnualChange].freeze
  DEFAULT_ASPECT_CATEGORIES = [''].freeze
  DEFAULT_COMMON_STATS = %w[salesVolume].freeze

  parse_param_list = lambda { |value, _context|
    if empty_value?(value)
      nil
    else
      [value].map { |v| v.split(',') }.flatten.map(&:to_sym)
    end
  }

  VALIDATIONS = {
    from: ->(value, _context)    { empty_value?(value) ? nil : Date.strptime(value, '%Y-%m') },
    to: ->(value, _context)      { empty_value?(value) ? nil : Date.strptime(value, '%Y-%m') },
    _now: ->(value, _context)    { empty_value?(value) ? nil : Date.parse(value) },
    region: ->(value, _context)  { empty_value?(value) ? nil : value },
    rt: ->(value, _context)      { Regions.parse_region_type(value) },
    ai: parse_param_list,
    ac: parse_param_list,
    cs: parse_param_list
  }.freeze

  WHITELIST = VALIDATIONS.keys

  DEFAULTS = {
    from: Date.today.prev_year,
    to: Date.today,
    region: Constants::DEFAULT_LOCATION,
    ai: DEFAULT_ASPECT_INDICATORS,
    ac: DEFAULT_ASPECT_CATEGORIES,
    cs: DEFAULT_COMMON_STATS
  }.freeze

  def initialize(params)
    @params = params[:_scrubbed] || scrub_params(params)
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

  def method_missing(key, *_args)
    WHITELIST.include?(key.to_sym) ? value_of(key.to_sym) : super
  end

  def respond_to_missing?(method, _args = nil)
    WHITELIST.include?(method.to_sym)
  end

  def with(p, v)
    UserPreferences.new(_scrubbed: @params.merge(p => v))
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

  def self.empty_value?(v)
    v.nil? || v == ''
  end

  private

  def value_of(param)
    @params[param] || DEFAULTS[param]
  end

  def scrub_params(params)
    whitelisted = params
                  .symbolize_keys
                  .select { |key| WHITELIST.include?(key) }
    context = { params: whitelisted }

    validate_params(whitelisted, context)
  end

  def validate_params(params, context)
    params.each_with_object({}) do |pair, memo|
      k = pair.first
      sanitized = sanitize_user_input(pair.second)
      memo[k] = VALIDATIONS[k].call(sanitized, context)
    end
  end

  def sanitize_user_input(input)
    if input.is_a?(Array)
      input.map { |str| sanitize_user_input_string(str) }
    else
      Rails::Html::FullSanitizer.new.sanitize(input)
    end
  end

  def sanitize_user_input_string(str)
    Rails::Html::FullSanitizer.new.sanitize(str)
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
