# Command object to query the API for the latest available values
class LatestValuesCommand
  include DataService

  attr_reader :results

  def perform_query(service = nil)
    hpi = service_api(service)
    (hpi && run_query(hpi)) || no_service
  end

  private

  # Building the dataset only constructs a local object; it makes no request and
  # cannot raise a connection or service failure. The rescues that used to be
  # here were unreachable, and referenced `e` outside the scope where it was
  # bound, so they would have raised NameError had they ever run. Real API
  # failures surface from #run_query and are logged by ApiRequestLogSubscriber.
  def service_api(service)
    service || dataset(:ukhpi)
  end

  # Only upstream failures are caught, so the landing page can degrade to the
  # apology message when the data API is unavailable. Everything else, including
  # NoMethodError and ArgumentError, is a bug in our own code and propagates:
  # those used to be hidden behind the same friendly message, which made them
  # invisible in production.
  #
  # The failure itself is not logged here. ApiRequestLogSubscriber logs it once,
  # from the gem's instrumentation.
  def run_query(hpi)
    query = add_date_range_constraint(base_query)
    query = add_location_constraint(query)
    query = add_sort_constraint(query)
    query = add_limit_constraint(query)

    @results = hpi.query(query)
    true
  rescue Faraday::ConnectionFailed, DataServicesApi::ServiceException
    false
  end

  def add_date_range_constraint(query)
    query.ge('ukhpi:refMonth', default_month_year_value)
  end

  def default_month_year_value
    DataServicesApi::Value.year_month(Time.zone.now.year - 2, 1)
  end

  def add_location_constraint(query)
    value = DataServicesApi::Value.uri('http://landregistry.data.gov.uk/id/region/united-kingdom')
    query.eq('ukhpi:refRegion', value)
  end

  def add_sort_constraint(query)
    query.sort(:down, 'ukhpi:refMonth')
  end

  def add_limit_constraint(query)
    query.limit(1)
  end

  def no_service
    'Our apologies, but the latest index values are not available. Please check back again soon.'
  end
end
