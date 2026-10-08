# :nodoc:
class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TranslationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  before_action :set_locale
  before_action :change_default_caching_policy

  # Set the user's preferred locale. An explicit locale set via
  # the URL param `lang` is preeminent, otherwise we look to the
  # user's preferred language specified via browser headers. A `lang` we don't
  # support, including a blank one, is ignored rather than passed to I18n, which
  # would raise I18n::InvalidLocale
  def set_locale
    user_locale = params['lang'].presence_in(I18n.available_locales.map(&:to_s))
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

  # @return The given selections, if they are valid
  # @raise BadRequestError listing what was wrong with them, if not
  def validated(user_selections)
    return user_selections if user_selections.valid?

    raise BadRequestError.new('Invalid selections', user_selections: user_selections)
  end

  # @return The location URIs for the given GSS codes
  # @raise BadRequestError if any code does not name a location we know
  def location_uris_for_gss(gss_codes)
    gss_codes.map do |gss|
      Locations.lookup_gss(gss)&.uri ||
        raise(BadRequestError, "Location code not understood: #{gss}")
    end
  end
end
