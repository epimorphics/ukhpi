# Command object to query the API for the latest available values
class LatestValuesCommand
  include DataService

  attr_reader :results

  def perform_query(service = nil)
    hpi = service_api(service)
    (hpi && run_query(hpi)) || no_service
  end

  private

  def service_api(service)
    begin
      # Set service to ukhpi dataset if not already set
      service ||= dataset(:ukhpi)
    rescue Faraday::ConnectionFailed => e
      message = 'Failed to connect to UKHPI service'
      service = nil
    rescue DataServicesApi::ServiceException => e
      message = 'Failed to get response from UKHPI service'
      service = nil
    rescue RuntimeError => e
      message = "Runtime error #{e.inspect}"
      service = nil
    end

    if service.nil?
      log_fields = { message: message, service: service, params: {} }

      log_fields[:body] = "Caused by: #{e.cause} in " if e.cause
      log_fields[:body] += "\r\n(#{e.class})" if Rails.logger.debug?
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.logger.debug?
      log_fields[:request_status] = 'error'
      log_fields[:status] = e.status

      # Log the request status and response if there's an error
      Rails.logger.error(log_fields)
    end
    # Always return the service object, even if it's nil
    service
  end

  def run_query(hpi)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)

    success = true
    query = add_date_range_constraint(base_query)
    query = add_location_constraint(query)
    query = add_sort_constraint(query)
    query = add_limit_constraint(query)

    begin
      @results = hpi.query(query)
    rescue NoMethodError => e
      message = "Data API request failed with: NoMethodError: #{e}"
      status = 405 # Method Not Allowed
      success = false
    rescue ArgumentError => e
      message = "Data API request failed with: ArgumentError: #{e}"
      status = 422 # Unprocessable Entity
      success = false
    rescue RuntimeError => e
      message = "Data API request failed with: #{e}"
      status = 400 # Bad Request
      success = false
    rescue StandardError => e
      message = "Application failed with: #{e}"
      status = 500 # Internal Server Error
      success = false
    end

    if success == false # log the error if the request was unsuccessful
      # Calculate the time taken to execute the query and pass in the details to be logged
      time_taken = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000
      log_fields = { message: message, service: 'ukhpi', params: {} }
      log_fields[:request_status] = 'error'
      log_fields[:request_time] = time_taken
      log_fields[:status] = status

      if (400..499).cover?(status)
        Rails.logger.warn(log_fields)
      else
        Rails.logger.error(log_fields)
      end
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
