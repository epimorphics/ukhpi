# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base # rubocop:disable Metrics/ClassLength
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TranslationHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :change_default_caching_policy

  around_action :log_request_result

  # Set the user's preferred locale. An explicit locale set via
  # the URL param `lang` is preeminent, otherwise we look to the
  # user's preferred language specified via browser headers
  def set_locale
    user_locale = params['lang']
    user_locale ||= http_accept_language.compatible_language_from(I18n.available_locales)

    I18n.locale = user_locale if Rails.application.config.welsh_language_enabled
  end

  # * Set cache control headers for HMLR apps to be public and cacheable
  # * UHPI needs to be shorter to avoid delay (in users cache) on the
  # * publication deadline so it is set for 2 minutes (120 seconds)
  # Sets the default `Cache-Control` header for all requests,
  # unless overridden in the action
  def change_default_caching_policy
    expires_in 2.minutes, public: true, must_revalidate: true if Rails.env.production?
  end

  def log_request_result
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
    yield
    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start
    detailed_log_result(duration)
  end

  # Handle specific types of exceptions and render the appropriate error page
  # or attempt to render a generic error page if no specific error page exists
  unless Rails.application.config.consider_all_requests_local
    rescue_from StandardError do |e|
      # Trigger the appropriate error handling method based on the exception
      case e.class
      when ActionController::RoutingError, ActionView::MissingTemplate
        :render404
      when ActionController::InvalidCrossOriginRequest
        :render403
      when ActionController::BadRequest, ActionController::ParameterMissing
        :render400
      else
        :handle_internal_error
      end
    end
  end

  # Render the appropriate error page based on the exception
  def handle_internal_error(exception)
    if exception.instance_of? ArgumentError
      render_error(400)
    else
      Rails.logger.warn "No explicit error page for exception #{exception} - #{exception.class}"
      # Instrument ActiveSupport::Notifications for internal server errors only:
      sentry_code = instrument_internal_error(exception)
      render_error(500, sentry_code)
    end
  end

  def render_400(_exception = nil) # rubocop:disable Naming/VariableNumber
    render_error(400)
  end

  def render_403(_exception = nil) # rubocop:disable Naming/VariableNumber
    render_error(403)
  end

  def render_404(_exception = nil) # rubocop:disable Naming/VariableNumber
    render_error(404)
  end

  def render_500(_exception = nil) # rubocop:disable Naming/VariableNumber
    render_error(500)
  end

  def render_error(status, sentry_code = nil)
    reset_response

    status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] if status.is_a?(Symbol)
    @view_state ||= LandingState.new(UserLanguageSelection.new(params))

    respond_to do |format|
      format.html { render_html_error_page(status, sentry_code) }
      # Anything else returns the status as human readable plain string
      format.all { render plain: Rack::Utils::HTTP_STATUS_CODES[status].to_s, status: status }
    end
  end

  def render_html_error_page(status, sentry_code)
    render 'exceptions/error_page',
           locals: { status: status, sentry_code: sentry_code },
           layout: true,
           status: status
  end

  def render_request_error(user_selections, status_code)
    # Convert status code to integer if it is a symbol
    status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status_code] if status_code.is_a?(Symbol)
    respond_to do |format|
      @view_state ||= { user_selections: user_selections }
      format.html { render_html_error_page(status_code, nil) }

      format.json do
        render(json: { status: 'request error' }, status: status_code)
      end
    end
  end

  def reset_response
    self.response_body = nil
  end

  private

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def detailed_log_result(duration)
    env = request.env
    query = env['QUERY_STRING'] || URI.parse(env['REQUEST_URI']).query
    log_fields = {
      message: response.message || Rack::Utils::HTTP_STATUS_CODES[response.status],
      path: env['REQUEST_PATH'] || URI.parse(env['REQUEST_URI']).path,
      request_id: env['X_REQUEST_ID'],
      request_time: (duration / 1000) || env['REQUEST_TIME'], # in milliseconds
      method: request.method,
      status: response.status
    }

    log_fields[:path] = "#{log_fields[:path]}?#{query}" if query.present?

    if log_fields[:message] == 'OK' && log_fields[:status] == 200
      log_fields[:message] = 'Completed request'
      log_fields[:request_status] = 'completed'
    end

    if env['HTTP_USER_AGENT'] && Rails.env.production?
      log_fields[:user_agent] = env['HTTP_USER_AGENT']
    end

    if (500..599).include?(Rack::Utils::SYMBOL_TO_STATUS_CODE[response.status])
      log_fields[:message] = env['action_dispatch.exception'].to_s
      log_fields[:backtrace] = env['action_dispatch.backtrace'].join("\n") unless Rails.env.production?
    end

    if log_fields[:request_time]
      log_fields[:message] += format(', time taken: %.0f ms', log_fields[:request_time])
      seconds, milliseconds = log_fields[:request_time].divmod(1000)
      log_fields[:request_time] = format('%.0f.%03d', seconds, milliseconds) # rubocop:disable Style/FormatStringToken
    end

    log_response(response.status, log_fields.sort.to_h)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength

  # Log the error with the appropriate log level based on the status code
  def log_response(status, error_log)
    case status
    when 500..599
      Rails.logger.error(JSON.generate(error_log))
    when 400..499
      Rails.logger.warn(JSON.generate(error_log))
    else
      Rails.logger.info(JSON.generate(error_log))
    end
  end

  # Notify subscriber(s) of an internal error event with the payload of the
  # exception once done
  # @param [exc] exp the exception that caused the error
  # @return [ActiveSupport::Notifications::Event] provides an object-oriented
  # interface to the event
  # rubocop:disable Metrics/AbcSize
  def instrument_internal_error(exc, status = nil)
    err = {
      message: exc&.message || exc,
      status: Rack::Utils::SYMBOL_TO_STATUS_CODE[exc]
    }
    err[:status] = status if status
    err[:type] = exc.class&.name if exc&.class
    err[:cause] = exc&.cause if exc&.cause
    err[:backtrace] = exc&.backtrace if exc&.backtrace && Rails.env.development?
    # Log the exception to the Rails logger with the appropriate severity
    Rails.logger.send(err[:status] < 500 ? :warn : :error, JSON.generate(err))
    # Return unless the status code is 500 or greater to ensure subscribers are NOT notified
    return nil unless err[:status] >= 500

    sevent = Sentry.capture_exception(exc) unless Rails.env.development?
    # Instrument the internal error event to notify subscribers of the error
    ActiveSupport::Notifications.instrument('internal_error.application', exception: err)
    # Return the event id for the internal error event
    sevent&.event_id
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
