# Subscribe to :data_services_api events
class ApiRequestLogSubscriber < ActiveSupport::Subscriber
  attach_to :data_services_api

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
end
