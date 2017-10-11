# frozen-string-literal: true

# Shared functionality for user models that provide access to the users'
# choices articulated via the params in the incoming request
module UserChoices
  Struct.new('UserParam', :default_value, :'array?', :alias)

  attr_reader :params

  # @return A new UserSelections object in which the parameter `param` has
  # the value `val` instead of the current value. Does not change this
  # UserSelections object
  def with(param, val)
    new_params =
      if array_valued?(param)
        new_values = (param_or_default(param) + [val]).uniq
        @params.merge(param => new_values)
      else
        @params.merge(param => val)
      end

    UserSelections.new(__safe_params: new_params)
  end

  # @return A new UserSelections object in which the parameter `param` has
  # been removed. Does not change this UserSelections object
  def without(param, val)
    if array_valued?(param)
      new_values = param_or_default(param).reject { |v| v == val }
      new_params = params.to_h.merge(param => new_values)
    else
      new_params = params.reject { |key, _val| key == param }
    end

    UserSelections.new(__safe_params: new_params)
  end

  # Return the param value for the given key, or if that is nil:
  # * return the value of the alias key if that has a value (legacy support)
  # * return the default value
  def param_or_default(key)
    return params[key] unless params[key].nil?
    if (alt_key = alternative_key(key)) && params[alt_key]
      return params[alt_key]
    end

    user_params_model[key].default_value
  end

  def alternative_key(k)
    user_params_model
      .find { |_key, value| value.alias == k }
      &.first
  end

  def parse_date(date)
    date.is_a?(String) ? Date.parse(date) : date
  end

  def array_valued?(param)
    user_params_model[param]&.array?
  end
end
