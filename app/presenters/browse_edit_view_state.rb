# frozen-string-literal: true

require_dependency 'active_support/core_ext/module/delegation'

# Adapter mapping the view state in a browse controller to the browse view
class BrowseEditViewState
  attr_reader :user_selections
  attr_reader :matched_locations

  def initialize(params)
    @user_selections = UserSelections.new(params)
  end

  delegate :location_search_term, to: :user_selections
  delegate :location_search_type, to: :user_selections
  delegate :selected_location, to: :user_selections
  delegate :selected_themes, to: :user_selections

  def location_type_options
    Locations.location_search_options
  end

  def selected_location_label
    loc = selected_location
    loc && Locations.location_label(loc)
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

  def data_cube
    @data_cube ||= UkhpiDataCube.new
  end

  def selected_param?(param_type, value_slug)
    case param_type
    when :indicator then user_selections.selected_indicators
    when :statistic then user_selections.selected_statistics
    end .include?(value_slug)
  end

  def selected_theme?(theme)
    selected_themes.include?(theme.slug)
  end
end
