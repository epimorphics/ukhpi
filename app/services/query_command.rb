# frozen_string_literal: true

# Class encapsulating the user action of making a UKHPI query
class QueryCommand
  include DataService

  attr_reader :user_selections, :results, :query

  def initialize(user_selections)
    @user_selections = user_selections
    @query = build_query
  end

  # Perform the UKHPI query encapsulated by this command object
  # @param service Optional API service end-point to use. Defaults to the UKHPI
  # API service endpoint
  def perform_query(service = nil)
    log_fields = {}
    time_taken = execute_query(service, query)
    log_fields[:message] = format("Completed Data Services API roundtrip took %.0fms\n", time_taken)
    log_fields[:request_status] = 'completed'
    log_fields[:duration] = time_taken
    Rails.logger.info(log_fields)
  end

  # @return True if this a query execution command
  def query_command?
    true
  end

  # @return True if this is a query explanation command
  def explain_query_command?
    false
  end

  private

  # Construct the DsAPI query that matches the given user constraints
  def build_query
    log_fields = {}
    log_fields[:message] = 'Received Data Services API query'
    log_fields[:request_status] = 'received'
    query = add_date_range_constraint(base_query)
    query1 = add_location_constraint(query)
    add_sort(query1)
    Rails.logger.info(log_fields)
  end

  def api_service(service)
    @api_service ||= service || default_service
  end

  def default_service
    dataset(:ukhpi)
  end

  # Run the given query, stash the results, and return time taken in microseconds.
  def execute_query(service, query)
    log_fields = {}
    log_fields[:message] = 'Processing Data Services API query'
    log_fields[:request_status] = 'processing'
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
    @results = api_service(service).query(query)
    Rails.logger.info(log_fields)
    (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000
  end

  def add_date_range_constraint(query)
    from = month_year_value(user_selections.from_date)
    to = month_year_value(user_selections.to_date)

    query.ge('ukhpi:refMonth', from)
         .le('ukhpi:refMonth', to)
  end

  def add_location_constraint(query)
    value = DataServicesApi::Value.uri(location_uri)
    query.eq('ukhpi:refRegion', value)
  end

  def add_sort(query)
    query.sort(:up, 'ukhpi:refMonth')
  end

  def month_year_value(date)
    DataServicesApi::Value.year_month(date.year, date.month)
  end

  def location_uri
    user_selections.selected_location
  end
end
