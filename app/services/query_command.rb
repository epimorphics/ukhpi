# Class encapsulating the user action of making a UKHPI query
class QueryCommand
  include DataService

  attr_reader :user_selections, :results, :query

  # Create a new UKHPI query command object
  # @param [UserSelections] user_selections the user's selections
  # @return [QueryCommand] the new command object
  def initialize(user_selections)
    @user_selections = user_selections
    @query = build_query
  end

  # Perform the UKHPI query encapsulated by this command object
  # @param [DataServicesApi::Service] service the API service to use
  # Defaults to the UKHPI API service endpoint
  def perform_query(service = nil)
    execute_query(service, query) / 1000
  end

  # @return True if this a query execution command
  def query_command?
    true
  end

  # @return True if this is a query explanation command
  def explain_query_command?
    true
  end

  private

  # Construct the DsAPI query that matches the given user constraints
  def build_query
    query = add_date_range_constraint(base_query)
    query1 = add_location_constraint(query)
    add_sort(query1)
  end

  # @return [DataServicesApi::Service] the API service to use
  def api_service(service)
    @api_service ||= service || default_service
  end

  # @return [DataServicesApi::Service] the default API service to use
  def default_service
    dataset(:ukhpi)
  end

  # Execute the given query using the given service
  # @param [DataServicesApi::Service] service the API service to use
  # @param [DataServicesApi::Query] query the query to execute
  # @return [Integer] the time taken to execute the query in microseconds
  def execute_query(service, query)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)

    begin
      @results = api_service(service).query(query)
    rescue Faraday::ConnectionFailed, DataServicesApi::ServiceException, RuntimeError
      # Swallow: the failure (and its status/backtrace) is already logged by
      # ApiRequestLogSubscriber via the data_services_api gem's instrumentation.
    end

    # Always return the time taken to execute the query, even on failure
    (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000
  end

  # Add a date range constraint to the given query
  # @param [DataServicesApi::Query] query the query to add the constraint to
  # @return [DataServicesApi::Query] the modified query
  def add_date_range_constraint(query)
    from = month_year_value(user_selections.from_date)
    to = month_year_value(user_selections.to_date)

    query.ge('ukhpi:refMonth', from)
         .le('ukhpi:refMonth', to)
  end

  # Add a location constraint to the given query
  # @param [DataServicesApi::Query] query the query to add the constraint to
  # @return [DataServicesApi::Query] the modified query
  def add_location_constraint(query)
    value = DataServicesApi::Value.uri(location_uri)
    query.eq('ukhpi:refRegion', value)
  end

  # Add a sort constraint to the given query
  # @param [DataServicesApi::Query] query the query to add the constraint to
  # @return [DataServicesApi::Query] the modified query
  def add_sort(query)
    query.sort(:up, 'ukhpi:refMonth')
  end

  # Convert provided date to a year-month value
  # @param [Date] date the date to convert
  # @return [DataServicesApi::Value] the year-month value
  def month_year_value(date)
    DataServicesApi::Value.year_month(date.year, date.month)
  end

  # @return [String] the URI of the selected location
  def location_uri
    user_selections.selected_location
  end
end
