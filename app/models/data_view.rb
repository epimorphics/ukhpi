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
    add_remove_param(add, 'thm', theme.slug)
  end

  # Invoke a block for each of this theme's statisics
  def each_statistic(&block)
    theme.statistics.each(&block)
  end

  # @return True if a given statistic is selected for this theme
  def statistic_selected?(statistic)
    user_selections.selected_statistics.include?(statistic.slug)
  end

  # @return The link location for adding or removing a statistic from a theme
  def add_remove_statistic(add, statistic)
    add_remove_param(add, 'st', statistic.slug)
  end

  # @return The data from the query, formatted in way that's suitable for
  # rendering in a table
  def as_table_data
    columns = as_table_columns(theme, user_selections)
    data = project_data(query_result, columns)
    { columns: columns, data: data }
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

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end

  def add_remove_param(add, param, value)
    adjacent_selections = user_selections.send(add ? :with : :without, param, value)
    "?#{UserSelectionsPresenter.new(adjacent_selections).as_url_search_string}"
  end

  def as_table_columns(theme, user_selections)
    [{ label: 'Date', pred: 'ukhpi:refMonth' }] +
      ukhpi.theme(theme.slug).statistics.map do |statistic|
        if user_selections.selected_statistics.include?(statistic.slug)
          { label: I18n.t(statistic.slug), pred: pred_name(theme, statistic) }
        end
      end .compact
  end

  def pred_name(theme, statistic)
    
  end
end
