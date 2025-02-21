# frozen_string_literal: true

# :nodoc:
class LoggingHelper
  def self.log_request(fields, type = 'info') # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    puts "\n" if Rails.env.development? && Rails.logger.debug? # rubocop:disable Rails/Output
    # Extract service and params from fields hash
    service = fields[:service] if fields[:service].respond_to?(:data_api)
    fields[:params].presence
    # Set the service and params keys to nil for later removal
    fields[:service] = nil
    fields[:params] = nil
    # Set default values for log fields
    fields[:message] ||= 'Received request'
    fields[:method] ||= 'GET'

    fields[:path] ||= nil
    if service.respond_to?(:data_api) && fields[:path].blank?
      fields[:path] = URI.parse(service.data_api).path
      # elsif params
      #   fields[:path] += "?#{JSON.generate(params)}"
    end

    fields[:message] += ": #{fields[:path]}" if fields[:path]

    fields[:request_status] ||= 'received'
    fields[:request_time] ||= fields[:duration]

    if fields[:request_time]
      fields[:message] += format(', time taken: %.0f ms', fields[:request_time])
    end

    fields[:status] ||= Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]

    fields.compact! # Finally, remove any nil values before sending to the logger

    Rails.logger.send(type) { JSON.generate(fields.sort.to_h) } unless fields.empty?
    Rails.logger.flush if Rails.logger.respond_to?(:flush)
  end
end
