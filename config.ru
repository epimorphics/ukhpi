# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

require ::File.expand_path('config/environment', __dir__)

unless Rails.env.test?
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'

  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

if ENV['RAILS_ENV'] == 'production'
  map Rails.application.config.relative_url_root || '/' do
    run Rails.application
  end
else
  run Rails.application
end
