# frozen-string-literal: true

# Concern encapsulating the validations that we apply to incoming parameters
# that will form the basis for the UserPreferences
module ParameterValidations
  # Convert an encoded list of parameter values into an array of symbols
  validate_symbol_list = lambda { |value, _context|
    if empty_value?(value)
      nil
    else
      Array(value)
        .map { |v| v.split(',') }
        .flatten
        .map(&:to_sym)
    end
  }

  # Validation rules for controller parameters
  VALIDATIONS = {
    from: ->(value, _context) { empty_value?(value) ? nil : Date.strptime(value, '%Y-%m') },
    to: ->(value, _context) { empty_value?(value) ? nil : Date.strptime(value, '%Y-%m') },
    _now: ->(value, _context) { empty_value?(value) ? nil : Date.parse(value) },
    region: ->(value, _context) { empty_value?(value) ? nil : value },
    rt: ->(value, _context) { Regions.parse_region_type(value) },
    ai: validate_symbol_list,
    ac: validate_symbol_list,
    cs: validate_symbol_list
  }.freeze

  WHITELIST = VALIDATIONS.keys

  def self.empty_value?(v)
    v.nil? || v == ''
  end

  def scrub_params(raw_params)
    valid_params = raw_params.permit!
    validate_params(valid_params.to_h)
  end

  def validate_params(params)
    params.each_with_object({}) do |pair, memo|
      param, value = *pair
      validator = VALIDATIONS[param.to_sym]
      memo[param.to_sym] = validator.call(sanitize_user_input(value), params) if validator
      memo
    end
  end

  def sanitize_user_input(input)
    input.is_a?(Array) ? input.map { |s| sanitize_string(s) } : sanitize_string(input)
  end

  def sanitize_string(str)
    Rails::Html::FullSanitizer.new.sanitize(str)
  end
end
