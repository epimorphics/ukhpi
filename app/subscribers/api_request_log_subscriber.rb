# Logs every interaction with the data API, once, from the gem's own
# instrumentation. Service objects should not log API calls themselves: doing so
# duplicates these entries and drifts out of step with the gem's retry behaviour.
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
    # Only array bodies have a row count; an explain query returns a Hash, and
    # claiming "0 rows" for one would be misleading.
    returned_rows = response.body.size if response.body.is_a?(Array)

    message = if returned_rows
                "API returned #{returned_rows} row#{'s' unless returned_rows == 1}, time taken: #{duration} ms"
    else
                "API responded, time taken: #{duration} ms"
    end

    Rails.logger.info(
      {
        message: message,
        method: response.env.method.to_s.upcase,
        path: url.query ? "#{url.path}?#{url.query}" : url.path,
        request_status: 'processing',
        request_time: (duration / 1000.0).round(3),
        returned_rows: returned_rows,
        status: response.status,
      }.compact
    )
  end

  # WARN, not ERROR: a retry that is about to happen is recoverable.
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

  # ERROR is right even though the incoming request may still render: this
  # operation cannot recover. request_status stays 'processing' because one
  # failed upstream call is not the terminal state of the incoming request.
  def connection_failure(event)
    exception = event.payload[:exception]

    Rails.logger.error(
      {
        message: "API connection failure: #{exception.message} - #{exception.class.name}",
        request_status: 'processing',
        status: 503,
      }
    )
  end

  def service_exception(event)
    exception = event.payload[:exception]

    Rails.logger.error(
      {
        message: "API service exception: #{exception.message} - #{exception.class.name}",
        request_status: 'processing',
        status: exception.respond_to?(:status) ? exception.status : 502,
      }
    )
  end
end
