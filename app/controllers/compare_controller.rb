# frozen-string-literal: true

# Controller for the user action of copmaring statistics between two or more
# locations
class CompareController < ApplicationController
  layout 'webpack_application'

  def show
    user_compare_selections = UserCompareSelections.new(params)
    @view_state = CompareLocationsPresenter.new(user_compare_selections)
  end
end
