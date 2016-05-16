# Command object to query the API for the latest available values

class LatestValuesCommand
  include DataService

  attr_reader :results

  def initialize
  end

  def perform_query( service = nil )
    hpi = service || dataset( :ukhpi )

    query = add_date_range_constraint( base_query )
    query = add_location_constraint( query )
    query = add_sort_constraint( query )
    query = add_limit_constraint( query )

    Rails.logger.debug "About to ask DsAPI query: #{query.to_json}"
    Rails.logger.debug query.to_json
    start = Time.now
    @results = hpi.query( query )
    Rails.logger.debug( "query took %.1f ms\n" % ((Time.now - start) * 1000.0) )
  end

  :private

  def add_date_range_constraint( query )
    query.ge( "ukhpi:refPeriod", default_month_year_value )
  end

  def default_month_year_value
    DataServicesApi::Value.year_month( Time.now.year - 2, 1 )
  end

  def add_location_constraint( query )
    value = DataServicesApi::Value.uri( "http://landregistry.data.gov.uk/id/region/great-britain" )
    query.eq( "ukhpi:refRegion", value )
  end

  def add_sort_constraint( query )
    query.sort( :down, "ukhpi:refPeriod" )
  end

  def add_limit_constraint( query )
    query.limit( 1 )
  end

end
