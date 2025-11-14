# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0'

# Gems for front-end asset management
gem 'font-awesome-rails'
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier'
gem 'terser' # Updating to terser for ES6+ support
gem 'vite_rails'

# Gems for different use cases
gem 'csv'

# Faraday v2 requires individual middlewares to be specified
# Resolve open-ended gem versioning warnings by setting explicit version minimums
gem 'faraday', '~> 2.13', '>= 2.13.0'
gem 'faraday-encoding', '~> 0.0', '>= 0.0.6'
gem 'faraday-follow_redirects', '~> 0.4', '>= 0.4.0'
gem 'faraday-retry', '~> 2.0', '>= 2.0'

gem 'get_process_mem'
gem 'govuk_template'
gem 'haml-rails'
gem 'http_accept_language'
gem 'js-routes'
gem 'ostruct'
gem 'prometheus-client'
gem 'puma'
gem 'puma-metrics'
gem 'rdf-turtle'
gem 'rubocop', require: false
gem 'rubocop-rails', require: false
gem 'sentry-rails'
gem 'yajl-ruby', require: 'yajl'

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
  gem 'ruby-lsp'
  gem 'solargraph'
  # Original meta_request gem is broken. Using fork provided by rails_panel
  # (https://github.com/dejan/rails_panel/issues/209#issuecomment-2621877079_)
  gem 'meta_request', github: 'dejan/rails_panel', ref: 'meta_request-v0.8.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
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

# TODO: In production you want to set this to the gem from the epimorphics group package repository
source 'https://rubygems.pkg.github.com/epimorphics' do
  gem 'data_services_api'
  gem 'json_rails_logger'
end

# TODO: For gem development and testing, you can use the local path to the gem
# gem 'data_services_api', path: '~/Epimorphics/shared/data_services_api'
# gem 'json_rails_logger', path: '~/Epimorphics/shared/json-rails-logger'
