# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

require ::File.expand_path('config/environment', __dir__)

if ENV['RAILS_ENV'] != 'production'
    run Rails.application
else
  map Rails.application.config.relative_url_root || '/' do
    run Rails.application
  end
end
