# frozen_string_literal: true

# Presenter for the state needed to drive the changelog page
class LanguageState
  attr_reader :user_selections

  def initialize(user_selections)
    @user_selections = user_selections
  end
end
