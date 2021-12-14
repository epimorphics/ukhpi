# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem 'haml-rails'
gem 'webpacker'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

gem 'data_services_api', git: 'https://github.com/epimorphics/ds-api-ruby.git', branch: 'task/infrastructure-update'

gem 'json_rails_logger', git: 'https://github.com/epimorphics/json-rails-logger.git', branch: 'main'

gem 'font-awesome-rails'
gem 'sass-rails'

gem 'govuk_elements_rails'
gem 'govuk_frontend_toolkit', '~> 7.0'
gem 'govuk_template'
gem 'js-routes', '< 2.0'
gem 'sentry-raven'

gem 'faraday'
gem 'faraday_middleware'
gem 'http_accept_language'
gem 'puma'
gem 'rubocop-rails'
gem 'yajl-ruby', require: 'yajl'

gem 'rdf-turtle'

group :development, :test do
  gem 'byebug'
  gem 'capybara_minitest_spec'
  gem 'haml-lint'
  gem 'json_expressions'
  gem 'm'
  gem 'minitest-rails', '~> 6.0'
  gem 'minitest-reporters'
  # gem 'minitest-spec-rails'
  gem 'mocha'
  gem 'nokogiri'
  gem 'oj'
  gem 'rubocop', require: false
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'tzinfo-data'
  gem 'vcr'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
