# frozen-string-literal: true

# Adapter mapping the view state in a browse controller to the browse view
class BrowseViewState
  attr_reader :user_selections

  def initialize(params)
    @user_selections = UserSelections.new(params)
  end

  def location_type_options
    Regions.location_search_options
  end

  private

  def data_cube
    @data_cube ||= UkhpiDataCube.new
  end
end
