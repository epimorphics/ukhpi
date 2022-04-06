# frozen_string_literal: true

# Subscribe to :api events
class ApiPrometheusSubscriber < ActiveSupport::Subscriber
  attach_to :api

  def response(event) # rubocop:disable Metrics/MethodLength
    response = event.payload[:response]
    duration = event.payload[:duration]

    Prometheus::Client.registry
                      .get(:api_status)
                      .increment(labels: { status: response.status.to_s })
    Prometheus::Client.registry
                      .get(:api_requests)
                      .increment(labels: { result: 'success' })
    Prometheus::Client.registry
                      .get(:api_response_times)
                      .observe(duration)
  end

  def connection_failure(event)
    message = event.payload[:exception]
    Prometheus::Client.registry
                      .get(:api_requests)
                      .increment(labels: { result: 'failure' })
    Prometheus::Client.registry
                      .get(:api_connection_failure)
                      .increment(labels: { message: message.to_s })
  end

  def service_exception(event)
    message = event.payload[:exception]
    Prometheus::Client.registry
                      .get(:api_service_exception)
                      .increment(labels: { message: message.to_s })
  end
end
