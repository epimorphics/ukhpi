# Command object to query the API for the latest available values

class LatestValuesCommand
  include DataService

  attr_reader :results

  def initialize
  end

  def perform_query( service = nil )
    hpi = service_api( service )

    hpi ? run_query( hpi ) : no_service
  end

  :private

  def service_api( service )
    begin
      service || dataset( :ukhpi )
    rescue Faraday::ConnectionFailed => e
      Rails.logger.info( "Failed to connect to UK HPI " )
      Rails.logger.info( e )
      nil
    end
  end

  def run_query( hpi )
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

  def add_date_range_constraint( query )
    query.ge( "ukhpi:refMonth", default_month_year_value )
  end

  def default_month_year_value
    DataServicesApi::Value.year_month( Time.now.year - 2, 1 )
  end

  def add_location_constraint( query )
    value = DataServicesApi::Value.uri( "http://landregistry.data.gov.uk/id/region/united-kingdom" )
    query.eq( "ukhpi:refRegion", value )
  end

  def add_sort_constraint( query )
    query.sort( :down, "ukhpi:refMonth" )
  end

  def add_limit_constraint( query )
    query.limit( 1 )
  end

  def no_service
    "Our apologies, but the latest index values are not available. Please check back again soon."
  end
end
