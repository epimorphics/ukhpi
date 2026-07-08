# Subscribe to :api events
class ApiPrometheusSubscriber < ActiveSupport::Subscriber
  attach_to :api

  def response(event)
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
                      .observe(duration.to_i)
  end

  def connection_failure(event)
    exception = event.payload[:exception]
    Prometheus::Client.registry
                      .get(:api_requests)
                      .increment(labels: { result: 'failure' })
    Prometheus::Client.registry
                      .get(:api_connection_failure)
                      .increment(labels: { message: exception.to_s })

    Log.error(
      "API connection failure: #{exception.message}",
      {
        error_class: exception.class.name,
        status: 503,
      }
    )
  end

  def service_exception(event)
    exception = event.payload[:exception]
    Prometheus::Client.registry
                      .get(:api_service_exception)
                      .increment(labels: { message: exception.to_s })

    Log.error(
      "API service exception: #{exception.message}",
      {
        error_class: exception.class.name,
        status: exception.respond_to?(:status) ? exception.status : 502,
      }
    )
  end
end
