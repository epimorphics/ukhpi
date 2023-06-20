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

  def service_api(service) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    service || dataset(:ukhpi)
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error('Failed to connect to UK HPI ')
    Rails.logger.error("Status: #{e.status}, body: '#{e.message}'")
    Rails.logger.error(e)
    nil
  rescue DataServicesApi::ServiceException => e
    Rails.logger.error('Failed to get response from UK HPI service')
    Rails.logger.error("Status: #{e.status}, body: '#{e.service_message}'")
    nil
  rescue RuntimeError => e
    Rails.logger.error { "Runtime error #{e.inspect}" }
    Rails.logger.error(e.class)
    Rails.logger.error(e.backtrace.join("\n"))
    Rails.logger.error { "Caused by: #{e.cause}" } if e.cause
    nil
  end

  def run_query(hpi) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    success = true
    query = add_date_range_constraint(base_query)
    query = add_location_constraint(query)
    query = add_sort_constraint(query)
    query = add_limit_constraint(query)

    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
    begin
      @results = hpi.query(query)
    rescue RuntimeError => e
      Rails.logger.error("API query failed with: #{e.inspect}")
      success = false
    end
    time_taken = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start)
    Rails.logger.info(format("API query '#{query.to_json}' completed in %.0f μs\n", time_taken))
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
