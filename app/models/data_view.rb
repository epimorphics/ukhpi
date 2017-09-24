# frozen-string-literal: true

require_dependency 'active_support/core_ext/module/delegation'

# Domain model object encapsulating a particular data view in the UI, based
# around a particular theme group of indicators in the cube. For example,
# a view of the  `averagePrice` indicator, together with the relevant dates,
# location and other options, and access to the underlying data, to enable
# the renderer to draw the display
class DataView
  attr_reader :user_selections
  attr_reader :query_result
  attr_reader :indicator
  attr_reader :theme

  def initialize(user_selections:, query_result:, indicator:, theme:)
    @user_selections = user_selections
    @query_result = query_result
    @indicator = indicator
    @theme = theme
  end

  delegate :from_date, to: :user_selections
  delegate :to_date, to: :user_selections
  delegate :selected_location, to: :user_selections

  # @return The title for this view, taking into account the indicator and
  # the theme name
  def title
    indicator ? title_with_indicator : title_without_indicator
  end

  # @return The label for the currently selected location
  def selected_location_label
    @selected_location_label ||=
      Locations.lookup_location(selected_location)
               .label
  end

  # @return True if a data view should be visible, given the indicator and theme
  def visible?
    user_selections.selected_themes.include?(theme.slug) &&
      (!indicator || user_selections.selected_indicators.include?(indicator.slug))
  end

  # @return The link location for showing or hiding a data view by adding or
  # removing the theme from the selected themes
  def add_remove_theme_link(add)
    adjacent_selections = user_selections.send(add ? :with : :without, 'thm', theme.slug)
    "?#{UserSelectionsPresenter.new(adjacent_selections).as_url_search_string}"
  end

  private

  def title_with_indicator
    "#{I18n.t(indicator.label_key)}, by #{I18n.t(title_key).downcase}"
  end

  def title_without_indicator
    I18n.t(title_key)
  end

  def title_key
    theme.slug
  end
end
