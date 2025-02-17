# frozen_string_literal: true

require 'version'

Rails.application.reloader.to_prepare do
  if ENV['SENTRY_API_KEY']
    Sentry.init do |config|
      # https://docs.sentry.io/platforms/ruby/configuration/options/#breadcrumbs-logger
      config.breadcrumbs_logger = %i[sentry_logger monotonic_active_support_logger http_logger]
      # The DSN tells the SDK where to send events.
      config.dsn = ENV['SENTRY_API_KEY']
      # Only report errors in these environments:
      config.enabled_environments = %w[production prod preprod dev]
      # Ignore exceptions that are not useful to us
      config.excluded_exceptions += [
        'ActionController::BadRequest',
        'ActionController::RoutingError',
        'ActiveRecord::RecordNotFound'
      ]
      # Set the environment name from the DEPLOYMENT_ENVIRONMENT environment variable
      config.environment = ENV.fetch('DEPLOYMENT_ENVIRONMENT', Rails.env)
      ## Default to only reporting info, warnings and errors to Sentry
      config.logger.level = Rails.application.config.log_level || :info
      # Set the release version to the current version
      config.release = Version::VERSION
      # Set traces_sample_rate to 1.0 to capture 100% of transactions for tracing.
      # Sentry recommends adjusting this value in production hence the ternary operator.
      config.traces_sample_rate = Rails.env.development? ? 1.0 : 0.1
      # Set profiles_sample_rate to profile 100% of sampled transactions.
      # Sentry recommends adjusting this value in production hence the ternary operator.
      config.profiles_sample_rate = Rails.env.production? ? 1.0 : 0.1
    end
  end
end
