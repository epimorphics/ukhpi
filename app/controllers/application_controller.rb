# :nodoc:
class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TranslationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  before_action :set_locale
  before_action :change_default_caching_policy

  # Order matters: rescue_from resolves to the most recently registered
  # matching handler, so the specific ApplicationRequestError handler must
  # be registered after the generic StandardError one to take precedence.
  unless Rails.application.config.consider_all_requests_local
    rescue_from StandardError, with: :render_unexpected_error
  end
  rescue_from ApplicationRequestError, with: :render_application_request_error

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

  def version
    render json: { version: Version::VERSION }
  end

  private

  def render_unexpected_error(exception)
    log_fields = {
      message: "Unhandled exception: #{exception.message} (#{exception.class.name})",
      request_status: 'error',
      status: 500,
    }
    log_fields[:backtrace] = exception.backtrace&.join("\n") if Rails.env.development? || Rails.logger.debug?
    Rails.logger.error(log_fields.compact)

    Sentry.capture_exception(exception)

    render_application_request_error(
      ApplicationRequestError.new(nil, :internal_server_error, exception.message)
    )
  end

  def render_application_request_error(exception)
    status_code = exception.status
    status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status_code] if status_code.is_a?(Symbol)

    respond_to do |format|
      @view_state ||= { user_selections: exception.user_selections }
      format.html { render_html_error_page(status_code, nil) }
      format.json { render(json: { status: 'request error' }, status: status_code) }
    end
  end

  def render_html_error_page(status, sentry_code)
    render 'exceptions/error_page',
           layout: true,
           locals: { status: status, sentry_code: sentry_code },
           status: status
  end
end
