# Encapsulates the user's articulated preferences for filtering and displaying
# House Price Index data

class UserPreferences
  INTERIM_DATASET = false

  DEFAULT_ASPECT_INDICATORS = %w( housePriceIndex averagePrice percentageChange percentageAnnualChange )
  DEFAULT_ASPECT_CATEGORIES = [""]

  VALIDATIONS = {
    from: ->( value, context )    {empty_value?( value ) ? nil : Date.strptime( value, "%Y-%m" )},
    to: ->( value, context )      {empty_value?( value ) ? nil : Date.strptime( value, "%Y-%m" )},
    _now: ->( value, context )    {empty_value?( value ) ? nil : Date.parse( value )},
    region: ->( value, context )  {empty_value?( value ) ? nil : value},
    rt: ->( value, context )      {Regions.parse_region_type( value )},
    ai: ->( value, context ) {
      empty_value?( value ) ?
        nil :
        [value].map {|v| v.split(",")}.flatten.map( &:to_sym )
    },
    ac: ->( value, context ) {
      empty_value?( value ) ?
        nil :
        [value].map {|v| v.split(",")}.flatten.map( &:to_sym )
    }
  }

  WHITELIST = VALIDATIONS.keys

  DEFAULTS = {
    from: INTERIM_DATASET ? Date.new( 2013, 12, 31 ) : Date.today.prev_year,
    to: INTERIM_DATASET ? Date.new( 2014, 12, 31 ) : Date.today,
    region: Constants::DEFAULT_LOCATION,
    ai: DEFAULT_ASPECT_INDICATORS,
    ac: DEFAULT_ASPECT_CATEGORIES
  }

  def initialize( params )
    @params = params[:_scrubbed] || scrub_params( params )
    @params.freeze
  end

  def aspect_indicators
    value_of( :ai )
  end

  def aspect_categories
    value_of( :ac )
  end

  def method_missing( key, *args, &block )
    WHITELIST.include?( key.to_sym ) && value_of( key.to_sym )
  end

  def with( p, v )
    UserPreferences.new( _scrubbed: @params.merge( {p => v} ))
  end

  def as_search_string
    @params
      .map {|k,v| encode_as_search_string( k, v )}
      .sort
      .join( "&" )
  end

  def to_hash
    @params
  end

  def prefs
    self
  end

  def summary
    templates = {
      region: "%s",
      from: "from %s",
      to: "to %s"
    }

    apply_templates( templates, @params ).join( ", " )
  end

  :private

  def value_of( param )
    @params[param] || DEFAULTS[param]
  end

  def scrub_params( params )
    whitelisted = params
      .symbolize_keys
      .select {|key| WHITELIST.include?( key )}
    context = {params: whitelisted}

    validate_params( whitelisted, context )
  end

  def validate_params( params, context )
    params.inject( {} ) do |memo, pair|
      k = pair.first
      sanitized = sanitize_user_input( pair.second )
      memo[k] = VALIDATIONS[k].call( sanitized, context )
      memo
    end
  end

  def sanitize_user_input( input )
    if input.is_a?( Array )
      input.map {|str| sanitize_user_input_string( str )}
    else
      Rails::Html::FullSanitizer.new.sanitize( input )
    end
  end

  def sanitize_user_input_string( str )
    Rails::Html::FullSanitizer.new.sanitize( str )
  end

  def self.empty_value?( v )
    v == nil || v == ""
  end

  def encode_as_search_string( k, v )
    if v.is_a?( Array )
      v = v.map( &:to_s ).join( "," )
    end
    "#{URI.escape k.to_s}=#{URI.escape v.to_s}"
  end

  def apply_templates( templates, params )
    templates.map do |k, template|
      if value = params[k]
        region = Regions.lookup_region( value )
        value = region ? region.label : value
        template % value
      end
    end .compact
  end
end
