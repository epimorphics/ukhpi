# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0'

gem 'vite_rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

gem 'haml-rails'
# gem 'webpacker', '~> 5.4'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

gem 'font-awesome-rails'
gem 'sass-rails'

gem 'js-routes'

gem 'csv'
gem 'dotenv'
gem 'faraday'
gem 'faraday_middleware'
gem 'get_process_mem'
gem 'http_accept_language'
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
  gem 'json_expressions'
  gem 'nokogiri'
  gem 'oj'
  gem 'tzinfo-data'
end

group :development do
  gem 'haml-lint'
  gem 'htmlbeautifier'
  # Devtools panel for Rails development
  # https://chromewebstore.google.com/detail/rails-panel/gjpfobpafnhjhbajcjgccbbdofdckggg?pli=1
  gem 'meta_request'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'm'
  gem 'minitest-rails'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  # gem 'minitest-spec-rails'
  gem 'mocha'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'vcr'
end

# TODO: In production you want to set this to the gem from the epimorphics package repo
source 'https://rubygems.pkg.github.com/epimorphics' do
  gem 'data_services_api'
  gem 'json_rails_logger'
end

# TODO: For running the app locally for testing you can set this to your local path
# gem 'data_services_api', path: '~/Epimorphics/shared/data_services_api'
# gem 'json_rails_logger', path: '~/Epimorphics/shared/json-rails-logger'
