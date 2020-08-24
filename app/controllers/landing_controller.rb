# frozen_string_literal: true

# :nodoc:
class LandingController < ApplicationController
  def index
    @view_state = LandingState.new(UserLanguageSelection.new(params))
  end
end
