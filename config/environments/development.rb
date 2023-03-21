# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Don't print a log message every time an asset file is loaded
  config.assets.quiet = true

  # Tag rails logs with useful information
  config.log_tags = %i[subdomain request_id request_method]
  # When sync mode is true, all output is immediately flushed to the underlying
  # operating system and is not buffered by Ruby internally.
  $stdout.sync = true
  # Log the stdout output to the Epimorphics JSON logging gem
  config.logger = JsonRailsLogger::Logger.new($stdout)

  # The RAILS_RELATIVE_URL_ROOT should be specified in the entrypoint.sh script
  # but this passes in a standard root value in development if the app is run
  # directly via `rails server`
  config.relative_url_root = ENV.fetch('RAILS_RELATIVE_URL_ROOT', '/')

  # API_SERVICE_URL should also be specified in the entrypoint.sh file and
  # set in the Makefile as an env variable for the docker container when run as an image.
  # API_SERVICE_URL is required by both Docker image and Rails
  
  # API location can be specified in the environment
  # But defaults to the dev service
  config.api_service_url = ENV.fetch('API_SERVICE_URL', 'http://localhost:8080')

  # feature flag for showing the Welsh language switch affordance
  config.welsh_language_enabled = true

  # Use default paths for documentation.
  config.accessibility_document_path = '/doc/accessibility'
  config.privacy_document_path = '/doc/privacy'

  # Set the contact email address to Land Registry supplied address
  config.contact_email_address = 'data.services@mail.landregistry.gov.uk'
end
