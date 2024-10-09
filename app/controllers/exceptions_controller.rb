# frozen_string_literal: true

# Controller to handle dynamically displaying error messages
class ExceptionsController < ApplicationController
  layout 'application'

  def handle_error
    env = request.env
    exception = env['action_dispatch.exception']
    status_code = ActionDispatch::ExceptionWrapper.new(env, exception).status_code

    sentry_code = maybe_report_to_sentry(exception, status_code)

    # add the exception to the prometheus metrics but only on errors that are 404
    instrument_internal_error(exception) unless status_code == 404

    render :error_page,
           locals: { status: status_code, sentry_code: sentry_code },
           layout: true,
           status: status_code
  end

  private

  def maybe_report_to_sentry(exception, status_code)
    return nil if Rails.env.development? # Why are we reporting to Sentry in dev?
    return nil unless status_code >= 500

    sevent = Sentry.capture_exception(exception)
    sevent&.event_id
  end
end
