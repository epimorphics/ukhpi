# frozen-string-literal: true

# Controller to handle dynamically displaying error messages
class ExceptionsController < ApplicationController
  layout 'application'

  def render_error
    env = request.env
    exception = env['action_dispatch.exception']
    status_code = ActionDispatch::ExceptionWrapper.new(env, exception).status_code

    sentry_code = maybe_report_to_sentry(exception, status_code)

    render :error_page,
           locals: { status: status_code, sentry_code: sentry_code },
           layout: true,
           status: status_code
  end

  private

  def maybe_report_to_sentry(exception, status_code)
    return nil unless status_code >= 500

    Raven.capture_exception(exception)
    Raven.last_event_id
  end
end
