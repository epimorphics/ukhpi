# Class encapsulating the user action of making a UKHPI query

class QueryCommand
  include DataService
  INTERIM_DATASET = true

  attr_reader :prefs, :results

  def initialize( prefs )
    @prefs = prefs
  end

  def perform_query( service = nil )
    hpi = service || dataset( :ukhpi )

    query = add_date_range_constraint( base_query )
    query = add_location_constraint( query )

    Rails.logger.debug "About to ask DsAPI query: #{query.to_json}"
    puts query.to_json
    @results = hpi.query( query )
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
      from: default_anchor_date.prev_year,
      to: default_anchor_date
    }[key]
  end

  def default_anchor_date
    INTERIM_DATASET ? Date.new( 2014, 12, 31 ) : Date.today
  end

  def add_location_constraint( query )
    value = DataServicesApi::Value.uri( region_uri )
    query.eq( "ukhpi:refRegion", value )
  end

  def region_uri
    preference( :region_uri )
  end

end
