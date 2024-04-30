# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV.fetch('RAILS_SERVE_STATIC_FILES', true)

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Disable logging of the rendering of partials
  config.action_view.logger = nil

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to
  # config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Tag rails logs with useful information
  config.log_tags = %i[subdomain request_id request_method]
  # When sync mode is true, all output is immediately flushed to the underlying
  # operating system and is not buffered by Ruby internally.
  $stdout.sync = true
  # Log the stdout output to the Epimorphics JSON logging gem
  config.logger = JsonRailsLogger::Logger.new($stdout)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # * Set cache control headers for HMLR apps to be public and cacheable
  # * UHPI needs to be shorter to avoid delay (in users cache) on the
  # * publication deadline so it is set for 2 minutes (120 seconds)
  # This will affect assets served from /app/assets
  config.static_cache_control = "public, max-age=#{2.minutes.to_i}"

  # This will affect assets in /public, e.g. webpacker assets.
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{2.minutes.to_i}",
    'Expires' => 2.minutes.from_now.to_formatted_s(:rfc822)
  }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # The RAILS_RELATIVE_URL_ROOT env var should ONLY be used in a local environment.
  # Here, the default value is passed in as the compiled assets have no knowledge
  # of the base path and utilise the config.relative_url_root value to prefix the
  # compiled asset paths
  config.relative_url_root = ENV.fetch('RAILS_RELATIVE_URL_ROOT', '/app/ukhpi')

  # API location is specified in the environment variable API_SERVICE_URL
  config.api_service_url = ENV.fetch('API_SERVICE_URL', nil)

  # feature flag for showing the Welsh language switch affordance
  config.welsh_language_enabled = true

  # Use default paths for documentation.
  config.accessibility_document_path = '/accessibility'
  config.privacy_document_path = '/privacy'

  # Set the contact email address to Land Registry supplied address
  config.contact_email_address = 'data.services@mail.landregistry.gov.uk'
end
