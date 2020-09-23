# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  private

  # Set the user's preferred locale. An explicit locale set via
  # the URL param `lang` is preeminent, otherwise we look to the
  # user's preferred language specified via browser headers
  def set_locale
    user_locale =
      params['lang'] ||
      http_accept_language.compatible_language_from(I18n.available_locales)

    I18n.locale = user_locale if Rails.application.config.welsh_language_enabled
  end
end
