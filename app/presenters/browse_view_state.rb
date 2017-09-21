# frozen-string-literal: true

# Adapter mapping the view state in a browse controller to the browse view
class BrowseViewState
  attr_reader :user_selections
  attr_reader :matched_locations

  def initialize(params)
    @user_selections = UserSelections.new(params)
  end

  def location_type_options
    Regions.location_search_options
  end

  def selected_location
    user_selections.selected_location
  end

  def selected_location_label
    loc = selected_location
    loc && Regions.region_label(loc)
  end

  def location_search_term
    user_selections.location_search_term
  end

  def location_search_type
    user_selections.location_search_type
  end

  def add_matched_locations(locations)
    @matched_locations = locations
  end

  def location=(location)
    @user_selections =
      user_selections
      .with('location', location.uri)
      .without('location-term')
      .without('location-type')
      .without('form-action')
  end

  def with_location_path(location)
    selection_with_loc =
      user_selections
      .without('location-term')
      .without('location-type')
      .without('form-action')
      .with('location', location.uri)
    "?#{UserSelectionsPresenter.new(selection_with_loc).as_url_search_string}"
  end

  private

  def data_cube
    @data_cube ||= UkhpiDataCube.new
  end
end
