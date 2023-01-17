# frozen_string_literal: true

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
end
