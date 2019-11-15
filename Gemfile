# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '< 6.0.0'
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

gem 'data_services_api', git: 'https://github.com/epimorphics/ds-api-ruby.git'
# gem 'data_services_api', path: '/home/ian/workspace/epimorphics/ds-api-ruby'

gem 'font-awesome-rails'
gem 'sass-rails', '~> 5.0'

gem 'govuk_elements_rails'
gem 'govuk_frontend_toolkit', '~> 7.0'
gem 'govuk_template'
gem 'js-routes'
gem 'sentry-raven'

gem 'faraday'
gem 'faraday_middleware'
gem 'yajl-ruby', require: 'yajl'

gem 'rdf-turtle'

group :development, :test do
  gem 'byebug'
  gem 'capybara_minitest_spec'
  gem 'haml-lint'
  gem 'json_expressions'
  gem 'm'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'minitest-spec-rails'
  gem 'mocha'
  gem 'nokogiri'
  gem 'oj'
  gem 'rubocop', require: false
  gem 'simplecov', require: false
  gem 'tzinfo-data'
  gem 'vcr'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rubocop-rails'
end
