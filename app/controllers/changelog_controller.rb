# frozen_string_literal: true

# Simple controller for showing the changelog
class ChangelogController < ApplicationController
  def index
    Log.info(
      'Requesting Changelog Controller',
      { params: params, path: request.path, request_status: 'processing' }
    )
    @view_state = LanguageState.new(UserLanguageSelection.new(params))
  end
end
