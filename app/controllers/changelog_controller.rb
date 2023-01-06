# frozen_string_literal: true

# Simple controller for showing the changelog
class ChangelogController < ApplicationController
  def index
    @view_state = LanguageState.new(UserLanguageSelection.new(params))
  end
end
