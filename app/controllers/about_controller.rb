# frozen_string_literal: true

# Controller for routes 'about UKHPI'
class AboutController < ApplicationController
  def index
    @view_state = LanguageState.new(UserLanguageSelection.new(params))
  end
end
