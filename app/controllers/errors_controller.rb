# Renders the error pages. Reached only through `config.exceptions_app` (see
# config/application.rb), never through a route, so every request here carries
# the exception Rails caught.
#
# This controller renders. It does not decide which error occurred or what status
# it deserves: Rails has already done both, via `rescue_responses`, and passes the
# status as the request path.
class ErrorsController < ApplicationController
  layout 'application'

  # The failed request may have been a form POST, and its token is not ours to
  # check. A CSRF failure here would abandon the error page for Rails' bare
  # failsafe response.
  skip_forgery_protection

  # Error pages must not be served from a shared cache after the fault is fixed.
  skip_before_action :change_default_caching_policy

  PARSED_PARAMS = {
    'action_dispatch.request.query_parameters' => :GET,
    'action_dispatch.request.request_parameters' => :POST,
  }.freeze

  # The Rack entry point for `config.exceptions_app`.
  #
  # Rails reads the request's params while processing any controller action, before
  # the action runs. When the error being reported is that the params could not be
  # parsed, such as a malformed query string, that read raises again, and
  # ShowExceptions gives up and returns its plain-text failsafe 500. So treat params
  # that cannot be parsed as empty here: Request caches parsed params in these
  # headers, and a cached empty hash is never re-parsed.
  def self.render_error(env)
    request = ActionDispatch::Request.new(env)
    PARSED_PARAMS.each do |header, parse|
      request.public_send(parse)
    rescue ActionController::BadRequest
      env[header] = {}
    end

    action(:show).call(env)
  end

  def show
    status = Rack::Utils.status_code(request.path_info.delete_prefix('/').to_i)
    exception = request.get_header('action_dispatch.exception')
    # The action that failed, captured before the fallback below replaces it
    action = request.path_parameters.values_at(:controller, :action).compact.join('#').presence

    # The header's language switcher links with a bare params hash, which
    # `url_for` resolves against the route the request matched. A routing error
    # matched none, so resolve those links against the landing page instead:
    # switching language on a page that does not exist goes home. Requests that
    # did match a route, such as a 400 from /browse, keep it.
    request.path_parameters = { controller: 'landing', action: 'index' } if request.path_parameters.blank?

    # Deliberately not a LandingState: building one performs an upstream API call,
    # so rendering a 500 page would call the service that most likely caused it.
    @view_state = {
      user_selections: exception.try(:user_selections) || UserLanguageSelection.new(params),
      errors: exception.try(:errors) || [],
    }

    instrument_internal_error(exception, status, action)

    respond_to do |format|
      format.html { render 'exceptions/error_page', locals: { status: status, sentry_code: nil }, status: status }
      format.all { render plain: Rack::Utils::HTTP_STATUS_CODES[status].to_s, status: status }
    end
  end

  private

  # Feeds the `internal_application_error` Prometheus counter, previously
  # instrumented by ApplicationController's own exception handler.
  def instrument_internal_error(exception, status, action)
    return if status < 500

    ActiveSupport::Notifications.instrument(
      'internal_error.application',
      exception: {
        class: exception.class.name, action: action, message: exception.message, status: status,
      }
    )
  end
end
