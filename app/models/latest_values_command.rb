# frozen_string_literal: true

# Command object to query the API for the latest available values
class LatestValuesCommand
  include DataService

  attr_reader :results

  def initialize; end

  def perform_query(service = nil)
    hpi = service_api(service)

    (hpi && run_query(hpi)) || no_service
  end

  private

  def service_api(service) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    service || dataset(:ukhpi)
  rescue Faraday::ConnectionFailed => e
    Rails.logger.info('Failed to connect to UK HPI ')
    Rails.logger.info(e)
    nil
  rescue DataServicesApi::ServiceException => e
    Rails.logger.info('Failed to get response from UK HPI service')
    Rails.logger.info("Status: #{e.status}, body: '#{e.service_message}'")
    nil
  rescue RuntimeError => e
    Rails.logger.debug("Unexpected error #{e.inspect}")
    Rails.logger.debug(e.class)
    Rails.logger.debug(e.backtrace.join("\n"))
    Rails.logger.debug("Caused by: #{e.cause}") if e.cause
    nil
  end

  def run_query(hpi) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    success = true
    query = add_date_range_constraint(base_query)
    query = add_location_constraint(query)
    query = add_sort_constraint(query)
    query = add_limit_constraint(query)

    Rails.logger.debug "About to ask DsAPI query: #{query.to_json}"
    Rails.logger.debug query.to_json
    start = Time.zone.now
    begin
      @results = hpi.query(query)
    rescue RuntimeError => e
      Rails.logger.warn("DsAPI run_query failed with: #{e.inspect}")
      success = false
    end

    Rails.logger.debug(format("query took %.1f ms\n", ((Time.zone.now - start) * 1000.0)))
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
