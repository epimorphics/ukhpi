# frozen-string-literal: true

# Controller for the main user experience of browsing the UKHPI statistics.
# Usually the primary interaction will be via JavaScript and XHR, but we also
# support non-JS access by setting browse preferences in the `edit` action.
class BrowseController < ApplicationController
  def show
  end

  def edit
    @view_state = BrowseViewState.new(params)
  end

  # private

end
