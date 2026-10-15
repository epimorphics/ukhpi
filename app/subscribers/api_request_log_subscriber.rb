# Logs every interaction with the data API, once, from the gem's own
# instrumentation. Service objects should not log API calls themselves: doing so
# duplicates these entries and drifts out of step with the gem's retry behaviour.
#
# Each entry describes the call to the API, so its values go in `upstream_*`
# fields: epilog_rails uses `status`, `path` and `request_time` for the incoming
# request, and a field must mean the same thing on every line. request_status is
# always 'processing': the call is a step in handling the incoming request, whose
# received and completed entries epilog_rails logs. Messages follow the same
# shape as epilog_rails' entries, with times in seconds.
#
# Failures are WARN, not ERROR. Whoever handles a failure decides whether it is
# fatal, and this subscriber cannot know whether the request will recover. When it
# does not, epilog_rails' completed entry is the one ERROR for the request.
class ApiRequestLogSubscriber < ActiveSupport::Subscriber
  attach_to :data_services_api

  def request(event)
    Rails.logger.info(
      {
        message: "API #{method_and_path(event.payload)} sent",
        **upstream_call(event.payload),
        request_status: 'processing',
      }.compact
    )
  end

  def response(event)
    response = event.payload[:response]
    url = response.env.url
    path = url.query ? "#{url.path}?#{url.query}" : url.path
    method = response.env.method.to_s.upcase
    time = seconds(event.payload[:duration])
    # Only array bodies have a row count; an explain query returns a Hash, and
    # claiming "0 rows" for one would be misleading.
    returned_rows = response.body.size if response.body.is_a?(Array)
    rows = " returned #{returned_rows} row#{'s' unless returned_rows == 1}" if returned_rows

    Rails.logger.info(
      {
        message: "API #{method} #{path} (#{response.status})#{rows} in #{time}s",
        upstream_url: upstream_url,
        upstream_method: method,
        upstream_path: path,
        upstream_status: response.status,
        upstream_time: time,
        returned_rows: returned_rows,
        request_status: 'processing',
      }.compact
    )
  end

  # The gem is about to try the request again
  def retry(event)
    exception = event.payload[:exception]

    Rails.logger.warn(
      {
        message: "API #{method_and_path(event.payload)} raised #{exception.class.name} (#{exception.message}), " \
                 "retrying in #{event.payload[:will_retry_in].round(2)}s (attempt #{event.payload[:retry_count]})",
        **upstream_call(event.payload),
        retry_count: event.payload[:retry_count],
        exception: exception.class.name,
        request_status: 'processing',
      }.compact
    )
  end

  # The API could not be reached, or did not answer in time, after any retries.
  # No response arrived, so no status is logged: the gem's payload carries a
  # fixed 503 that the API never sent.
  def connection_failure(event)
    log_failure(event, status: nil)
  end

  # The API answered, but with an error status or a body that could not be read
  def service_exception(event)
    log_failure(event, status: event.payload[:status])
  end

  private

  def log_failure(event, status:)
    exception = event.payload[:exception]
    time = seconds(event.payload[:duration])
    message = if status
                "API #{method_and_path(event.payload)} (#{status}) in #{time}s"
    else
                "API #{method_and_path(event.payload)} raised #{exception.class.name} (#{exception.message}) after #{time}s"
    end

    Rails.logger.warn(
      {
        message: message,
        **upstream_call(event.payload),
        upstream_status: status,
        upstream_time: time,
        exception: exception.class.name,
        request_status: 'processing',
      }.compact
    )
  end

  def upstream_call(payload)
    {
      upstream_url: upstream_url,
      upstream_method: upstream_method(payload),
      upstream_path: path_with_query(payload),
    }
  end

  # The method and path, as epilog_rails gives them for the incoming request
  def method_and_path(payload)
    "#{upstream_method(payload)} #{path_with_query(payload)}"
  end

  # Only the retry event carries the method. The others can fall back to GET
  # because the gem sends nothing else: `perform_request` is only called through
  # `conn.get`.
  def upstream_method(payload)
    payload[:method] || 'GET'
  end

  def path_with_query(payload)
    payload[:query_string].present? ? "#{payload[:path]}?#{payload[:query_string]}" : payload[:path]
  end

  # The scheme, host and port of the configured API. A malformed URL is logged as
  # configured rather than raising: logging must not be what breaks the request.
  def upstream_url
    url = Rails.application.config.api_service_url
    return if url.blank?

    uri = URI.parse(url)
    return url unless uri.host

    port = ":#{uri.port}" unless uri.port == uri.default_port
    "#{uri.scheme}://#{uri.host}#{port}"
  rescue URI::InvalidURIError
    url
  end

  def seconds(milliseconds)
    (milliseconds / 1000.0).round(3) if milliseconds
  end
end
