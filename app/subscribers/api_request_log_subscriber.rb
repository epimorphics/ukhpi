# Subscribe to :data_services_api events
class ApiRequestLogSubscriber < ActiveSupport::Subscriber
  attach_to :data_services_api

  def request(event)
    query_string = event.payload[:query_string]
    path = query_string ? "#{event.payload[:path]}?#{query_string}" : event.payload[:path]

    Rails.logger.info(
      {
        message: "Calling API: #{event.payload[:method]} #{path}",
        method: event.payload[:method],
        path: path,
        request_status: 'processing',
      }.compact
    )
  end

  def response(event)
    response = event.payload[:response]
    duration = event.payload[:duration]
    url = response.env.url
    returned_rows = response.body.size if response.body.is_a?(Array)

    Rails.logger.info(
      {
        message: "API returned #{returned_rows || 0} row#{'s' unless returned_rows == 1}, " \
                  "time taken: #{duration} ms",
        method: response.env.method.to_s.upcase,
        path: url.query ? "#{url.path}?#{url.query}" : url.path,
        request_status: 'processing',
        request_time: format('%.3f', duration / 1000.0),
        returned_rows: returned_rows,
        status: response.status,
      }.compact
    )
  end

  def retry(event)
    exception = event.payload[:exception]

    Rails.logger.warn(
      {
        message: "Retrying API request after #{exception.class.name}: #{exception.message} " \
                  "(attempt #{event.payload[:retry_count]}, " \
                  "retrying in #{event.payload[:will_retry_in].round(2)}s)",
        method: event.payload[:method],
        path: event.payload[:path],
        request_status: 'processing',
      }.compact
    )
  end

  def connection_failure(event)
    exception = event.payload[:exception]

    Rails.logger.error(
      {
        message: "API connection failure: #{exception.message} - #{exception.class.name}",
        request_status: 'error',
        status: 503,
      }
    )
  end

  def service_exception(event)
    exception = event.payload[:exception]

    Rails.logger.error(
      {
        message: "API service exception: #{exception.message} - #{exception.class.name}",
        request_status: 'error',
        status: exception.respond_to?(:status) ? exception.status : 502,
      }
    )
  end
end
