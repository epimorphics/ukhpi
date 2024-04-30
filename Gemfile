# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem 'haml-rails'
gem 'webpacker', '~> 5.4', '>= 5.4.4'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

gem 'font-awesome-rails'
gem 'sass-rails'

gem 'govuk_elements_rails'
gem 'govuk_frontend_toolkit', '~> 7.0'
gem 'govuk_template'
gem 'js-routes', '< 2.0'

gem 'faraday'
gem 'faraday_middleware'
gem 'get_process_mem', '~> 0.2.7'
gem 'http_accept_language'
gem 'prometheus-client', '~> 4.0'
gem 'puma'
gem 'rdf-turtle'
gem 'rubocop-rails'
gem 'sentry-rails', '~> 5.7'
gem 'yajl-ruby', require: 'yajl'

group :development, :test do
  gem 'byebug'
  gem 'haml-lint'
  gem 'json_expressions'
  gem 'nokogiri', '1.13.10' # This is the highest version that supports Ruby 2.6
  gem 'oj', '3.14.2' # This is the highest version that supports Ruby 2.6
  gem 'rubocop', require: false
  gem 'tzinfo-data'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'capybara_minitest_spec'
  gem 'm'
  gem 'minitest-rails', '~> 6.0'
  gem 'minitest-reporters'
  # gem 'minitest-spec-rails'
  gem 'mocha'
  gem 'selenium-webdriver'
  gem 'simplecov', '0.22.0'
  gem 'vcr'
end

# TODO: For running the app locally for testing you can set this to your local path
# gem 'data_services_api', '~> 1.4.0', path: '~/Epimorphics/shared/data_services_api/'
# gem 'json_rails_logger', '~> 1.0.0', path: '~/Epimorphics/shared/json-rails-logger/'

# TODO: In production you want to set this to the gem from the epimorphics package repo
source 'https://rubygems.pkg.github.com/epimorphics' do
  gem 'data_services_api', '~> 1.4.0'
  gem 'json_rails_logger', '~> 1.0.0'
end
