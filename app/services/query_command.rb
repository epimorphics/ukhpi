# frozen_string_literal: true

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
  def perform_query(service = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    time_taken = execute_query(service, query) / 1000
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
  def execute_query(service, query) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    begin
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
      log_type = 'error'

      @results = api_service(service).query(query)
    rescue Faraday::ConnectionFailed => e
      log_fields = { message: e.message }
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.logger.debug?
      log_fields[:status] = 503 # Service Unavailable
    rescue DataServicesApi::ServiceException => e
      log_fields = { message: e.service_message }
      log_fields[:status] = 503 # Service Unavailable
    rescue RuntimeError => e
      log_fields = { message: "Runtime error #{e.inspect}" }
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.logger.debug?
      log_fields[:message] += "Caused by: #{e.cause}" if e.cause
      log_fields[:message] += " in (#{e.class})" if Rails.logger.debug?
      log_fields[:status] = 500 # Internal Server Error
    end

    # Calculate the time taken to execute the query and pass in the details to be logged
    time_taken = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000

    # Log the final request status and response if there's an error
    if log_fields.present?
      log_fields[:request_status] = 'error'
      log_fields[:request_time] = time_taken
      LoggingHelper.log_request(log_fields, log_type)
      puts "\n" if Rails.env.development? && Rails.logger.debug? # rubocop:disable Rails/Output
    end
    # Always return the time taken to execute the query
    time_taken
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
