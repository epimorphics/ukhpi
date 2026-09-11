require File.expand_path('boot', __dir__)

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ukhpi
  # :nodoc:
  class Application < Rails::Application
    # Set the Google Analytics ID, if available
    # This can be set in the environment variables or left as old value
    # for backwards compatibility.
    config.google_analytics_id = ENV.fetch('GOOGLE_ANALYTICS_ID', 'UA-21165003-6')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # feature flag for showing the Welsh language switch affordance
    config.welsh_language_enabled = true

    # Use default paths for documentation.
    config.accessibility_document_path = '/accessibility'
    config.privacy_document_path = '/privacy'

    # Set the contact email address to Land Registry supplied address
    config.contact_email_address = 'data.services@mail.landregistry.gov.uk'

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Add deflater to compress JSON payloads
    config.middleware.use Rack::Deflater

    # Render error pages through the application, rather than the static files in
    # public/, so they can be localised and use the application layout.
    #
    # ActionDispatch::ShowExceptions catches the exception, maps it to a status via
    # `rescue_responses` below, resets the response, and hands the request to
    # ErrorsController with the path rewritten to the status code. It runs outside
    # the router, so unlike `rescue_from` it also catches routing errors. The
    # application never decides which status an exception deserves.
    #
    # Dispatched straight to the controller rather than via `routes`, so the error
    # pages have no public URLs: requesting /500 directly is just an unmatched path.
    # The lambda defers the constant lookup until an error occurs, after autoloading
    # is set up.
    config.exceptions_app = ->(env) { ErrorsController.action(:show).call(env) }

    # Statuses for the errors the application raises deliberately. Rails already
    # knows the framework's own exceptions (RoutingError is 404, ParameterMissing
    # is 400, and so on), so only ours need registering.
    #
    # This map is class to status and is read once at boot, so a status that varies
    # per call site needs its own exception class rather than an attribute.
    config.action_dispatch.rescue_responses.merge!(
      'BadRequestError' => :bad_request,
      'UpstreamError' => :internal_server_error
    )

    # Expected failures (404, 400, 422, ...) are already recorded by the
    # request's completed log entry, so don't also log them as exceptions.
    config.action_dispatch.log_rescued_responses = false

    # Log genuine unhandled exceptions at ERROR, not FATAL. This is the Rails
    # 7.1+ default, which this app does not get because it never calls
    # `config.load_defaults`.
    config.action_dispatch.debug_exception_log_level = :error
  end
end

# Monkey-patch the bit of Rails that emits the start-up log message, so that it
# is written out in JSON format that our combined logging service can handle
module Rails
  # :nodoc:
  module Command
    # :nodoc:
    class ServerCommand
      def print_boot_information(server, url)
        msg = "Starting #{server} Rails #{Rails.version} in #{Rails.env}"
        msg += " on #{url}" if url
        info = {
          ts: DateTime.now.utc.strftime('%FT%T.%3NZ'),
          level: 'INFO',
          message: msg,
        }
        say info.to_json
      end
    end
  end
end
