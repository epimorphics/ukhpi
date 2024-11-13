# frozen_string_literal: true

# Command object to query the API for the latest available values
class LatestValuesCommand
  include DataService

  attr_reader :results

  def perform_query(service = nil)
    log_fields = {}
    log_fields[:message] = 'Received Data Services API query'
    log_fields[:request_status] = 'received'

    Rails.logger.info(JSON.generate(log_fields))
    hpi = service_api(service)

    (hpi && run_query(hpi)) || no_service
  end

  private

  def service_api(service) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    log_fields = {}
    service = nil if service.blank?
    begin
      service || dataset(:ukhpi)
      log_fields[:message] = 'Connected to UK HPI service'
      log_type = 'info'
    rescue Faraday::ConnectionFailed => e
      log_fields[:message] = 'Failed to connect to UK HPI service'
      log_fields[:status] = e.status
      log_fields[:body] = e.message
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.env.development?
      log_fields[:request_status] = 'error'

      service = nil
    rescue DataServicesApi::ServiceException => e
      log_fields[:message] = 'Failed to get response from UK HPI service'
      log_fields[:status] = e.status
      log_fields[:body] = e.service_message
      log_fields[:request_status] = 'error'

      service = nil
    rescue RuntimeError => e
      log_fields[:message] = "Runtime error #{e.inspect}"
      log_fields[:status] = e.status
      log_fields[:body] = "Caused by: #{e.cause} in " if e.cause
      log_fields[:body] += e.class
      log_fields[:backtrace] = e&.backtrace&.join("\n") if Rails.env.development?
      log_fields[:request_status] = 'error'

      service = nil
    end
    Rails.logger.send(log_type) { log_fields }
    service
  end

  def run_query(hpi) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    log_fields = {}

    success = true
    query = add_date_range_constraint(base_query)
    query = add_location_constraint(query)
    query = add_sort_constraint(query)
    query = add_limit_constraint(query)

    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
    begin
      @results = hpi.query(query)
      time_taken = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000
      message = format("Processing Data Services API query: '#{query.to_json}' in %.0fms", time_taken)
      log_fields[:duration] = time_taken
      log_fields[:message] = message
      log_fields[:request_status] = 'processing'
      log_type = 'info'
    rescue NoMethodError => e
      log_fields[:message] = "Application failed with: NoMethodError: #{e.inspect}"
      log_fields[:request_status] = 'error'
      log_type = 'error'
      success = false
    rescue ArgumentError => e
      log_fields[:message] = "Data Services API query failed with: ArgumentError: #{e.inspect}"
      log_fields[:request_status] = 'error'
      log_type = 'error'
      success = false
    rescue RuntimeError => e
      log_fields[:message] = "Data Services API query failed with: #{e.inspect}"
      log_fields[:request_status] = 'error'
      log_type = 'error'
      success = false
    end
    Rails.logger.send(log_type) { JSON.generate(log_fields) }
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
