# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale, :change_default_caching_policy

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def create_detailed_request_log(duration)
    env = request.env

    log_fields = {
      duration: duration,
      request_id: env['X_REQUEST_ID'],
      forwarded_for: env['X_FORWARDED_FOR'],
      path: env['REQUEST_PATH'],
      query_string: env['QUERY_STRING'],
      user_agent: env['HTTP_USER_AGENT'],
      accept: env['HTTP_ACCEPT'],
      body: request.body.gets&.gsub("\n", '\n'),
      method: request.method,
      status: response.status,
      message: Rack::Utils::HTTP_STATUS_CODES[response.status]
    }

    case response.status
    when 500..599
      log_fields[:message] = env['action_dispatch.exception']
      Rails.logger.error(JSON.generate(log_fields))
    when 400..499
      Rails.logger.warn(JSON.generate(log_fields))
    else
      Rails.logger.info(JSON.generate(log_fields))
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize


  # Set the user's preferred locale. An explicit locale set via
  # the URL param `lang` is preeminent, otherwise we look to the
  # user's preferred language specified via browser headers
  def set_locale
    user_locale =
      params['lang'] ||
      http_accept_language.compatible_language_from(I18n.available_locales)

    I18n.locale = user_locale if Rails.application.config.welsh_language_enabled
  end

  # * Set cache control headers for HMLR apps to be public and cacheable
  # * UHPI needs to be shorter to avoid delay (in users cache) on the
  # * publication deadline so it is set for 2 minutes (120 seconds)
  # Set the default `Cache-Control` header for all requests,
  # unless overridden in the action
  def change_default_caching_policy
    expires_in 2.minutes, public: true, must_revalidate: true if Rails.env.production?
  end
end
