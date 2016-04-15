# Encapsulates the user's articulated preferences for filtering and displaying
# House Price Index data

class UserPreferences
  VALIDATIONS = {
    from: ->( value, context )    {Date.parse( value )},
    to: ->( value, context )      {Date.parse( value )},
    _now: ->( value, context )    {Date.parse( value )},
    region: ->( value, context )  {(value != "" && value) || raise( "Missing location" )},
    rt: ->( value, context )      {Regions.parse_region_type( value )}
  }

  WHITELIST = VALIDATIONS.keys

  def initialize( params )
    whitelisted = params
      .symbolize_keys
      .select {|key| WHITELIST.include?( key )}
    context = {params: whitelisted}

    @params = validate_params( whitelisted, context )
  end

  def method_missing( key, *args, &block )
    WHITELIST.include?( key.to_sym ) && @params[key.to_sym]
  end

  :private

  def validate_params( params, context )
    params.inject( {} ) do |memo, pair|
      k = pair.first
      sanitized = sanitize_user_input( pair.second )
      memo[k] = VALIDATIONS[k].call( sanitized, context )
      memo
    end
  end

  def sanitize_user_input( str )
    Rails::Html::FullSanitizer.new.sanitize( str )
  end
end
