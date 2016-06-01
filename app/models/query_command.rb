# Class encapsulating the user action of making a UKHPI query

class QueryCommand
  include DataService

  attr_reader :prefs, :results

  def initialize( prefs )
    @prefs = prefs
  end

  def perform_query( service = nil )
    hpi = service || dataset( :ukhpi )

    query = add_date_range_constraint( base_query )
    query = add_location_constraint( query )

    Rails.logger.debug "About to ask DsAPI query: #{query.to_json}"
    Rails.logger.debug query.to_json
    start = Time.now
    @results = hpi.query( query )
    Rails.logger.debug( "query took %.1f ms\n" % ((Time.now - start) * 1000.0) )
  end

  def query_command?
    true
  end

  def explain_query_command?
    false
  end

  :private

  def preference( key )
    prefs.send( key )
  end

  def add_date_range_constraint( query )
    query.ge( "ukhpi:refMonth", month_year_value( :from ) )
         .le( "ukhpi:refMonth", month_year_value( :to ) )
  end

  def month_year_value( key )
    date = boundary_date( key )
    DataServicesApi::Value.year_month( date.year, date.month )
  end

  def boundary_date( key )
    preference( key )
  end

  def add_location_constraint( query )
    value = DataServicesApi::Value.uri( region_uri )
    query.eq( "ukhpi:refRegion", value )
  end

  def region_uri
    preference( :region_uri )
  end

end
