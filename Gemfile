# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: ".ruby-version"

# Web framework core
gem 'puma'
gem 'rails', '~> 8.1'

# HTTP client libraries
gem 'faraday', '~> 2.14'
gem 'faraday-encoding', '~> 0.0'
gem 'faraday-follow_redirects', '~> 0.5'
gem 'faraday-retry', '~> 2.0', '>= 2.0'

# Template and view helpers
gem 'govuk_template'
gem 'haml-rails'
gem 'http_accept_language'
gem 'js-routes'

# Data processing and utilities
gem 'csv'
gem 'ostruct'
gem 'rdf-turtle'
gem 'yajl-ruby', require: 'yajl'

# Error tracking and monitoring (production)
gem 'get_process_mem'
gem 'prometheus-client'
gem 'puma-metrics'
gem 'sentry-rails', '~> 6.0'

# Asset pipeline and front-end
gem 'bootsnap', require: false
gem 'font-awesome-rails'
gem 'sass-rails'
gem 'terser' # Updating to terser for ES6+ support
gem 'vite_rails'

group :development, :test do
  gem 'byebug'
  gem 'dotenv'
  gem 'json_expressions'
  gem 'nokogiri'
  gem 'oj'
  gem 'tzinfo-data'
end

group :development do
  gem 'foreman'
  gem 'haml-lint'
  gem 'htmlbeautifier'
  # Original meta_request gem is broken. Using fork provided by rails_panel
  # (https://github.com/dejan/rails_panel/issues/209#issuecomment-2621877079_)
  gem 'meta_request', github: 'dejan/rails_panel', ref: 'meta_request-v0.8.5'
  # Code quality and linting (development only)
  gem 'rubocop', '~> 1.0', require: false
  gem 'rubocop-capybara', '~> 2.0', require: false
  gem 'rubocop-rails', '~> 2.0', require: false
  gem 'rubocop-rails-omakase', '~> 1.1', require: false
  gem 'ruby-lsp'
  gem 'solargraph'
  # Spring speeds up development by keeping your application running in the background
  gem 'spring'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'capybara-playwright-driver'
  gem 'm'
  gem 'minitest-rails'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'mocha'
  gem 'simplecov', require: false
  gem 'vcr'
end

# Private gem source for Epimorphics packages
source 'https://rubygems.pkg.github.com/epimorphics' do
  gem 'data_services_api', '2.0.0.prerelease'
  gem 'epilog_rails', '0.2.0'
end

# TODO: For gem development and testing, you can use the local path to the gem
# gem 'data_services_api', path: '~/Epimorphics/shared/data_services_api'
# gem 'epilog_rails', path: '~/Epimorphics/shared/epilog_rails'
