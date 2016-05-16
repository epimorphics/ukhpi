class LandingController < ApplicationController
  def index
    @landing_state = LandingState.new
  end
end
