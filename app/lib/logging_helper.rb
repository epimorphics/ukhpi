# frozen_string_literal: true

# :nodoc:
class LoggingHelper
  def self.log_request(fields, type = 'info') # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    puts "\n" if Rails.env.development? && Rails.logger.debug? # rubocop:disable Rails/Output
    # Extract service and params from fields hash
    service = fields[:service] if fields[:service].respond_to?(:data_api)
    params = fields[:params] if fields[:params].presence
    # Set the service and params keys to nil for later removal
    fields[:service] = nil
    fields[:params] = nil
    # Set default values for log fields
    fields[:message] ||= 'Received request'

    fields[:path] ||= nil
    if service.respond_to?(:data_api) && fields[:path].blank?
      # TODO: Resolve this line once all services are updated to use the new fields
      # fields[:message] += ": #{service.data_api}"
      fields[:path] = URI.parse(service.data_api).path
    elsif params.present? && fields[:path].present?
      query = params.is_a?(Hash) ? params : params.except('permitted', 'controller', 'action').to_unsafe_h # rubocop:disable Layout/LineLength
      fields[:path] += "?#{query.map { |k, v| "#{k}=#{v}" }.join('&')}"
    end

    # TODO: Resolve this line once all services are updated to use the new fields
    # fields[:message] += ": #{fields[:path]}" if fields[:path].present?
    fields[:request_status] ||= 'received'
    fields[:request_time] ||= fields[:duration]

    if fields[:request_time]
      fields[:message] += format(', time taken: %.0f ms', fields[:request_time])
      seconds, milliseconds = fields[:request_time].divmod(1000)
      fields[:request_time] = format('%.0f.%03d', seconds, milliseconds) # rubocop:disable Style/FormatStringToken
    end

    fields[:status]

    fields.compact! # Finally, remove any nil values before sending to the logger

    Rails.logger.send(type) { JSON.generate(fields.sort.to_h) } unless fields.empty?
    Rails.logger.flush if Rails.logger.respond_to?(:flush)
  end
end
