# frozen_string_literal: true

# Command object to query the API for the latest available values
class LatestValuesCommand
  include DataService

  attr_reader :results

  def perform_query(service = nil)
    hpi = service_api(service)
    (hpi && run_query(hpi)) || no_service
  end

  private

  def service_api(service) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    log_fields = {}
    log_type = 'error'

    service = nil if service.blank?
    begin
      # Set service to ukhpi dataset if not already set
      service ||= dataset(:ukhpi)
    rescue Faraday::ConnectionFailed => e
      log_fields[:message] = 'Failed to connect to UKHPI service'
      log_fields[:body] = e.message
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.env.development?
      log_fields[:request_status] = log_type
      log_fields[:status] = e.status

      service = nil
    rescue DataServicesApi::ServiceException => e
      log_fields[:message] = 'Failed to get response from UKHPI service'
      log_fields[:body] = e.service_message
      log_fields[:request_status] = log_type
      log_fields[:status] = e.status

      service = nil
    rescue RuntimeError => e
      log_fields[:message] = "Runtime error #{e.inspect}"
      log_fields[:body] = "Caused by: #{e.cause} in " if e.cause
      log_fields[:body] += "\r\n(#{e.class})" if Rails.application.config.log_level == :debug
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.env.development?
      log_fields[:request_status] = log_type
      log_fields[:status] = e.status

      service = nil
    end

    LoggingHelper.log_request(log_fields, log_type) unless log_fields.empty?

    service
  end

  def run_query(hpi) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
    log_fields = {}
    log_type = 'error'
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)

    success = true
    query = add_date_range_constraint(base_query)
    query = add_location_constraint(query)
    query = add_sort_constraint(query)
    query = add_limit_constraint(query)

    # Log the initial request received, passing in the service and query params
    LoggingHelper.log_request({ service: hpi, params: query })

    begin
      @results = hpi.query(query)

      msg = 'completed Data Services API request from the UKHPI service'
      log_type = 'info'
    rescue NoMethodError => e
      msg = "application failed with: NoMethodError: #{e.inspect}"
      log_fields[:status] = 405
      success = false
    rescue ArgumentError => e
      msg = "Data Services API request failed with: ArgumentError: #{e.inspect}"
      log_fields[:status] = 422
      success = false
    rescue RuntimeError => e
      msg = "Data Services API request failed with: #{e.inspect}"
      log_fields[:status] = 400
      success = false
    end
    # Calculate the time taken to execute the query and pass in the details to be logged
    time_taken = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000
    msg += format(' in %.0f ms', time_taken) if time_taken.positive?
    log_fields[:message] = msg.upcase_first
    log_fields[:request_status] = success ? 'completed' : 'error'
    log_fields[:request_time] = time_taken
    log_fields[:status] = Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok] if success

    # Log the final request status and response
    LoggingHelper.log_request(log_fields, log_type) unless log_fields.empty?
    puts "\n" if Rails.env.development? && Rails.logger.debug? # rubocop:disable Rails/Output
    success
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
