# Logs every interaction with the data API, once, from the gem's own
# instrumentation. Service objects should not log API calls themselves: doing so
# duplicates these entries and drifts out of step with the gem's retry behaviour.
#
# Each entry describes the call to the API, so its values go in `upstream_*`
# fields: epilog_rails uses `status`, `path` and `request_time` for the incoming
# request, and a field must mean the same thing on every line. request_status is
# always 'processing': the call is a step in handling the incoming request, whose
# received and completed entries epilog_rails logs.
#
# Messages are plain sentences an operator can read without the fields: what
# happened, to which call, with the status, the time in seconds and the
# exception's own text. Class names stay in the `exception` field.
#
# Failures are WARN, not ERROR. Whoever handles a failure decides whether it is
# fatal, and this subscriber cannot know whether the request will recover. When it
# does not, epilog_rails' completed entry is the one ERROR for the request.
class ApiRequestLogSubscriber < ActiveSupport::Subscriber
  attach_to :data_services_api

  def request(event)
    Rails.logger.info(
      {
        message: "Calling API: #{method_and_path(event.payload)}",
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
    outcome = returned_rows ? "returned #{returned_rows} row#{'s' unless returned_rows == 1} for" : 'responded to'

    Rails.logger.info(
      {
        message: "API #{outcome} #{method} #{path} (status #{response.status}, #{time}s)",
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
        message: "Retrying API request #{method_and_path(event.payload)} " \
                 "in #{event.payload[:will_retry_in].round(2)}s (attempt #{event.payload[:retry_count]}): " \
                 "#{exception.message}",
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
    call = method_and_path(event.payload)
    time = seconds(event.payload[:duration])
    exception = event.payload[:exception]
    message = if exception.is_a?(Faraday::TimeoutError)
                "API did not respond in time to #{call} (#{time}s): #{exception.message}"
    else
                "Could not connect to the API for #{call} (#{time}s): #{exception.message}"
    end

    log_failure(event, message, status: nil)
  end

  # The API answered, but with an error status or a body that could not be read
  def service_exception(event)
    call = method_and_path(event.payload)
    time = seconds(event.payload[:duration])
    status = event.payload[:status]
    message = if status
                "API returned an error for #{call} (status #{status}, #{time}s)"
    else
                "API response to #{call} could not be read (#{time}s): #{event.payload[:exception].message}"
    end

    log_failure(event, message, status: status)
  end

  private

  def log_failure(event, message, status:)
    Rails.logger.warn(
      {
        message: message,
        **upstream_call(event.payload),
        upstream_status: status,
        upstream_time: seconds(event.payload[:duration]),
        exception: event.payload[:exception].class.name,
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

  # The call, as it appears in messages
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
