# frozen_string_literal: true

# :nodoc:
class LandingController < ApplicationController
  def index
    @view_state = LandingState.new(UserLanguageSelection.new(params))
  rescue StandardError => e
    status = if e.respond_to?(:status)
               e.status
             else
               Rack::Utils::SYMBOL_TO_STATUS_CODE[:internal_server_error]
             end
    render_request_error(UserLanguageSelection.new(params), status) unless Rails.env.development?
  end
end
