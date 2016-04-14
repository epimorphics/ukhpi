# Encapsulates the user's articulated preferences for filtering and displaying
# House Price Index data

class UserPreferences
  VALIDATIONS = {
    from: ->( value, params ) {Date.parse( value )},
    to: ->( value, params ) {Date.parse( value )},
    now: ->( value, params ) {Date.parse( value )},
    region: ->( value, params ) {Regions.parse_region( value, params )},
    rt: ->( value, params ) {Regions.parse_region_type( value )}
  }

  WHITELIST = VALIDATIONS.keys

  attr_reader :params

  def initialize( params )
    whitelisted = params.select {|k,v| WHITELIST.include?( k )}
    @params = whitelisted.map do |k, v|
      VALIDATIONS[k.to_sym].apply( v, whitelisted )
    end
  end
end
