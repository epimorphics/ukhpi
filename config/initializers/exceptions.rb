# frozen_string_literal: true

# Custom error handling via a Rack middleware action
Rails.application.config.exceptions_app =
  lambda do |env|
    ExceptionsController.action(:render_error).call(env)
  end
