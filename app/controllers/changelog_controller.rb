# Simple controller for showing the changelog
class ChangelogController < ApplicationController
  def index
    Log.info('Requesting Changelog Controller', { params: params, path: request.path })
    @view_state = LanguageState.new(UserLanguageSelection.new(params))
  end
end
