# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base # rubocop:disable Metrics/ClassLength
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TranslationHelper
  include Log

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  before_action :set_locale
  before_action :change_default_caching_policy

  around_action :log_response

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

  def log_response
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
    yield
    # Calculate elapsed time and convert to milliseconds
    duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000
    Log.info(
      'Processing request',
      {
        duration:,
        method: request.method,
        params:,
        path: request.path,
        request_status: 'processing',
        status: response.status
      }
    )
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
  def handle_internal_error(exception) # rubocop:disable Metrics/MethodLength
    # Render the appropriate error page based on the exception
    if exception.instance_of? ArgumentError
      render_error(400)
    else
      cname = exception.class.name
      logged_fields = {
        status: Rack::Utils::HTTP_STATUS_CODES[exception]
      }
      if Rails.env.development? || Rails.logger.debug?
        logged_fields[:backtrace] =
          exception.backtrace.join("\n")
      end
      Log.error(
        "No explicit error page for exception #{exception} - #{cname}",
        logged_fields
      )
      # Instrument ActiveSupport::Notifications for internal errors but only for 500 errors:
      instrument_application_error(exception)
      render_error(500)
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

    error_status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] if status.is_a?(Symbol)
    @view_state ||= LandingState.new(UserLanguageSelection.new(params))

    respond_to do |format|
      format.html { render_html_error_page(error_status, sentry_code) }
      # Anything else returns the status as human readable plain string
      format.all { render plain: Rack::Utils::HTTP_STATUS_CODES[status].to_s, status: error_status }
    end
  end

  def render_html_error_page(status, sentry_code)
    render 'exceptions/error_page',
           layout: true,
           locals: { status: status, sentry_code: sentry_code },
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

  def version
    render json: { version: Version::VERSION }
  end

  private

  def set_sentry_user
    return unless signed_in? && Rails.env.production?

    Sentry.configure_scope do |scope|
      scope.set_user(email: current_user.email)
    end
  end

  # Notify subscriber(s) of an internal error event with the payload of the
  # exception once done
  # @param [exc] exp the exception that caused the error
  # @return [ActiveSupport::Notifications::Event] provides an object-oriented
  # interface to the event
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def instrument_application_error(exc, status = nil)
    err = {
      message: exc&.message || exc,
      status: exc&.status || Rack::Utils::SYMBOL_TO_STATUS_CODE[exc]
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
