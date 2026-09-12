# :nodoc:
class LandingController < ApplicationController
  def index
    Log.info('Requesting Landing Controller', { params: params, path: request.path })
    @view_state = LandingState.new(UserLanguageSelection.new(params))
  end
end
