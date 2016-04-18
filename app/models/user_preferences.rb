# Encapsulates the user's articulated preferences for filtering and displaying
# House Price Index data

class UserPreferences
  VALIDATIONS = {
    from: ->( value, context )    {empty_value?( value ) ? nil : Date.parse( value )},
    to: ->( value, context )      {empty_value?( value ) ? nil : Date.parse( value )},
    _now: ->( value, context )    {empty_value?( value ) ? nil : Date.parse( value )},
    region: ->( value, context )  {(!empty_value?( value ) && value) || raise( ArgumentError, "Missing location" )},
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

  def with( p, v )
    UserPreferences.new( @params.merge( {p => v} ))
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

  def self.empty_value?( v )
    v == nil || v == ""
  end
end
