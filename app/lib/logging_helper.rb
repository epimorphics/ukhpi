# frozen_string_literal: true

# :nodoc:
class LoggingHelper
  def self.log_request(fields, type = 'info') # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    puts "\n" if Rails.env.development? && Rails.logger.debug? # rubocop:disable Rails/Output

    # Extract service and params from fields hash
    service = fields.delete(:service) if fields.key(:service)
    params = fields.delete(:params) if fields.key(:params)

    fields[:message] ||= 'Received Data Services API request from the UKHPI service'
    fields[:method] ||= 'GET'
    fields[:path] ||= URI.parse(service.data_api).path if service
    # fields[:request_path] ||= URI.parse(service.data_api).path if service
    fields[:query_string] ||= JSON.generate(params) if params
    fields[:request_status] ||= 'received'
    fields[:status] ||= Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]

    Rails.logger.send(type) { JSON.generate(fields.sort.to_h) } unless fields.empty?
    Rails.logger.flush if Rails.logger.respond_to?(:flush)
  end
end
