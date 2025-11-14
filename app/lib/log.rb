# frozen_string_literal: true

# This module provides logging functionality for the application.
# It includes methods for logging messages at different levels (debug, info, warn, error)
# and a method for logging requests with various fields.
# It also includes a method for logging messages with a specific status code and log level.
# The logging is done using the Rails logger, and the messages are formatted as JSON.
# The module is designed to be used as a singleton, so the methods are defined as module functions.
# The module also includes a method for logging error messages with a specific status code.
module Log
  module_function

  # Default fields for logging for reference
  # These fields are used to log the request and response details
  # The keys are the field names, and the values are the expected data types
  # Example: { method: 'GET', path: '/' }
  LOG_FIELDS = {
    # HTTP request or response body
    body: 'string',
    # The logged message, should include time taken to process the event (in ms)
    # - use an integer value
    message: 'string',
    # HTTP method
    method: %w[GET POST PUT DELETE PATCH],
    # HTTP request path
    path: 'string',
    # HTTP request parameters as a stringified JSON object
    query_params: 'string',
    # HTTP response status code
    status: 'number',
    # The number of rows / records returned by a request
    returned_rows: 'number',
    # The status of a request
    request_status: %w[received processing complete],
    # Time taken to process the event (in seconds) - maybe a float/decimal value
    request_time: 'number'
  }.freeze

  def debug(message, fields = {})
    fields[:log_level] = :debug
    make_log(message, fields)
  end

  def info(message, fields = {})
    fields[:log_level] = :info
    make_log(message, fields)
  end

  def warn(message, fields = {})
    fields[:log_level] = :warn
    make_log(message, fields)
  end

  def error(message, fields = {})
    fields[:log_level] = :error
    make_log(message, fields)
  end

  # Log a request with the given fields and type
  def make_log(message, fields = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    puts "\n" if Rails.env.development? && Rails.logger.debug? # rubocop:disable Rails/Output

    # * Set initial values for logged fields
    # ! fields[:message] = "#{action} request for #{message}".humanize if message.present?
    fields[:message] = message if message.present?

    # * Set the request status based on the presence of request_time or duration
    action = fields[:request_time] || fields[:duration] ? 'processing' : 'received'
    fields[:request_status] ||= action

    # * Apply duration to request_time if request_time is not present
    # * This is to ensure that the request_time is always set
    fields[:request_time] ||= fields[:duration]

    # * Set the duration key to nil for later removal as this field is deprecated
    fields[:duration] = nil if fields[:duration].present?

    if fields[:request_time] && fields[:message].present?
      fields[:message] += format(', time taken: %.0f ms', fields[:request_time])
      seconds, milliseconds = fields[:request_time].divmod(1000)
      fields[:request_time] = format('%.0f.%03d', seconds, milliseconds)
    end

    # * Extract service and params from fields hash
    service = fields[:service] if fields[:service].respond_to?(:api)
    fields[:service] = nil
    params = fields[:params] if fields[:params].presence
    fields[:params] = nil

    fields[:path] ||= URI.parse(fields[:url]).path if fields[:url].present?
    fields[:url] = nil

    if service.respond_to?(:api) && fields[:path].blank?
      fields[:path] = URI.parse(service.api).path
    elsif params.present? && fields[:path].present?
      query = params.is_a?(Hash) && params.except('permitted', 'controller', 'action')
      fields[:path] += "?#{query.map { |k, v| "#{k}=#{v}" }.join('&')}" if query.present?
    end

    # * Set the request method to the HTTP method if not present
    fields[:method] ||= fields[:http_method]
    fields[:http_method] = nil

    # * Set the appropriate status level based on the status code
    if fields[:status].is_a?(Symbol)
      fields[:status] = Rack::Utils::SYMBOL_TO_STATUS_CODE[fields[:status]]
    end

    # * Set the log level and then remove it from the fields hash
    level = fields[:log_level]
    fields[:log_level] = nil

    # * If the message is nil, set the log level to debug to avoid logging empty messages in production
    level = :debug if fields[:message].nil?

    # * Finally, remove any nil values before sending to the logger
    fields.compact!

    maybe_log(fields[:status], fields.sort.to_h, level)
    puts "\n" if Rails.env.development? && Rails.logger.debug? # rubocop:disable Rails/Output
  end

  # Set the appropriate log level passed in or based on the status code
  # @param [Integer] status - the status code of the response
  # @param [Hash] logs - the log fields to include
  # @param [Symbol] level - the log level to use
  # @return [void]
  def maybe_log(status, logs, level = nil)
    level = :info if level.nil?
    level = :warn if (400..499).cover?(status) && level.nil?
    level = :error if (500..599).cover?(status) && level.nil?
    send_log(level, logs) unless logs.empty?
  end

  # Log the message with the appropriate log level
  def send_log(level, logs)
    Rails.logger.send(level) do
      JSON.generate(logs)
    end
    Rails.logger.flush if Rails.logger.respond_to?(:flush)
  end
end
