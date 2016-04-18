# Class encapsulating the user action of making a UKHPI query

class QueryCommand
  include DataService

  attr_reader :prefs

  def initialize( prefs )
    @prefs = prefs
  end

  def perform_query( service = nil )
    hpi = service || dataset( :ukhpi )

    query = add_date_range_constraint( base_query )
    query = add_location_constraint( query )

    Rails.logger.debug "About to ask DsAPI query: #{query.to_json}"
    puts query.to_json
    hpi.query( query )
  end

  def query_command?
    true
  end

  :private

  def preference( key )
    prefs.send( key )
  end

  def add_date_range_constraint( query )
    query.ge( "ukhpi:refPeriod", month_year_value( :from ) )
         .le( "ukhpi:refPeriod", month_year_value( :to ) )
  end

  def month_year_value( key )
    date = boundary_date( key )
    DataServicesApi::Value.year_month( date.year, date.month )
  end

  def boundary_date( key )
    preference( key ) || default_date( key )
  end

  def default_date( key )
    {
      from: Date.today.prev_year,
      to: Date.today
    }[key]
  end

  def add_location_constraint( query )
    value = DataServicesApi::Value.uri( region_uri )
    query.eq( "ukhpi:refRegion", value )
  end

  def region_uri
    preference( :region_uri )
  end

end
