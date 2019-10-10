# frozen-string-literal: true

Raven.configure do |config|
  config.dsn = 'https://1150348b449a444bb3ac47ddd82b37c4:5fd368489fe44c0f83f1f2e5df10a7ef@sentry.io/251669'
  config.current_environment = ENV['DEPLOYMENT_ENVIRONMENT'] || Rails.env
  config.environments = %w[production test]
  config.release = Version::VERSION
end
