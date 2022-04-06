# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ukhpi
  # :nodoc:
  class Application < Rails::Application
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Add deflater to compress JSON payloads
    config.middleware.use Rack::Deflater
  end
end

# Monkey-patch the bit of Rails that emits the start-up log message, so that it
# is written out in JSON format that our combined logging service can handle
module Rails
  # :nodoc:
  module Command
    # :nodoc:
    class ServerCommand
      def print_boot_information(server, url)
        msg = {
          level: 'INFO',
          ts: DateTime.now.rfc3339(3),
          message: "Starting #{server} Rails #{Rails.version} in #{Rails.env} #{url}"
        }
        say msg.to_json
      end
    end
  end
end
