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
    begin
      log_type = 'error'
      # Set service to ukhpi dataset if not already set
      service ||= dataset(:ukhpi)
    rescue Faraday::ConnectionFailed => e
      log_fields = { message: 'Failed to connect to UKHPI service' }
      log_fields[:body] = e.message if Rails.logger.debug?
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.logger.debug?
      log_fields[:request_status] = log_type
      log_fields[:status] = e.status

      service = nil
    rescue DataServicesApi::ServiceException => e
      log_fields = { message: 'Failed to get response from UKHPI service' }
      log_fields[:body] = e.service_message if Rails.logger.debug?
      log_fields[:request_status] = log_type
      log_fields[:status] = e.status

      service = nil
    rescue RuntimeError => e
      log_fields = { message: "Runtime error #{e.inspect}" }
      log_fields[:body] = "Caused by: #{e.cause} in " if e.cause
      log_fields[:body] += "\r\n(#{e.class})" if Rails.logger.debug?
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.logger.debug?
      log_fields[:request_status] = log_type
      log_fields[:status] = e.status

      service = nil
    end
    # Log the request status and response if there's an error
    LoggingHelper.log_request(log_fields, log_type) if service.nil?
    # Always return the service object, even if it's nil
    service
  end

  def run_query(hpi) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)

    success = true
    query = add_date_range_constraint(base_query)
    query = add_location_constraint(query)
    query = add_sort_constraint(query)
    query = add_limit_constraint(query)

    begin
      @results = hpi.query(query)
    rescue NoMethodError => e
      log_fields = { message: "Data API request failed with: NoMethodError: #{e}"}
      log_fields[:status] = 405 # Method Not Allowed
      success = false
    rescue ArgumentError => e
      log_fields = { message: "Data API request failed with: ArgumentError: #{e}"}
      log_fields[:status] = 422 # Unprocessable Entity
      success = false
    rescue RuntimeError => e
      log_fields = { message: "Data API request failed with: #{e}"}
      log_fields[:status] = 400 # Bad Request
      success = false
    rescue StandardError => e
      log_fields = { message: "Application failed with: #{e}"}
      log_fields[:status] = 500 # Internal Server Error
      success = false
    end

    if success == false # log the error if the request was unsuccessful
      # Calculate the time taken to execute the query and pass in the details to be logged
      time_taken = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000
      log_fields[:request_status] = 'error'
      log_fields[:request_time] = time_taken

      log_type = 'warn' if (400..499).cover?(log_fields[:status])
      log_type = 'error' unless success
      # Log the final request status and response
      LoggingHelper.log_request(log_fields, log_type)
      puts "\n" if Rails.env.development? && Rails.logger.debug? # rubocop:disable Rails/Output
    end

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
