# frozen_string_literal: true

# Class encapsulating the user action of making a UKHPI query
class QueryCommand
  include DataService

  MILLISECONDS = 1000.0

  attr_reader :user_selections
  attr_reader :results
  attr_reader :query

  def initialize(user_selections)
    @user_selections = user_selections
    @query = build_query
  end

  # Perform the UKHPI query encapsulated by this command object
  # @param service Optional API service end-point to use. Defaults to the UKHPI
  # API service endpoint
  def perform_query(service = nil)
    Rails.logger.debug "About to ask DsAPI query: #{query.to_json}"
    Rails.logger.debug query.to_json
    time_taken = execute_query(service, query)
    Rails.logger.debug(format("query took %.1f ms\n", time_taken))
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
    query = add_date_range_constraint(base_query)
    add_location_constraint(query)
  end

  def api_service(service)
    @api_service ||= service || default_service
  end

  def default_service
    dataset(:ukhpi)
  end

  # Run the given query, and stash the results. Return time taken in ms.
  def execute_query(service, query)
    start = Time.now
    @results = api_service(service).query(query)
    (Time.now - start) * MILLISECONDS
  end

  def add_date_range_constraint(query)
    from = month_year_value(user_selections.from_date)
    to = month_year_value(user_selections.to_date)

    query.ge('ukhpi:refMonth', from)
         .le('ukhpi:refMonth', to)
  end

  def add_location_constraint(query)
    value = DataServicesApi::Value.uri(region_uri)
    query.eq('ukhpi:refRegion', value)
  end

  def month_year_value(date)
    DataServicesApi::Value.year_month(date.year, date.month)
  end

  def region_uri
    user_selections.selected_region
  end
end
