# Includeable module for objects that interact with the data services API
module DataService
  attr_reader :default_service_name

  def initialize(default_service_name = nil)
    @default_service_name = default_service_name
  end

  # Return a data service object
  def data_service
    DataServicesApi::Service.new(url: api_service_url)
  end

  # Return a dataset wrapper object for the named dataset
  def dataset(ds_id)
    data_service.dataset(service_name(ds_id))
  end

  # Return a new empty query generator
  def base_query
    DataServicesApi::QueryGenerator.new
  end

  def service_name(service)
    (service || default_service_name).to_s
  end

  def api_service_url
    Rails.application.config.api_service_url
  end

  # Run an API call, re-raising a 4xx as ApiQueryError: the API rejected a query
  # we built, which is our bug, not an outage. Other failures pass through as
  # handled API errors.
  #
  # The cause is dropped deliberately. Sentry excludes ServiceException, and it
  # checks causes when excluding, so with the cause attached this bug would never
  # reach Sentry. The message keeps the API's own.
  def classify_api_errors
    yield
  rescue DataServicesApi::ServiceException => e
    raise unless e.status.to_i.between?(400, 499)

    raise ApiQueryError, "Data API rejected the query (#{e.status}): #{e.message}", cause: nil
  end
end
