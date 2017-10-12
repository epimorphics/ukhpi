# frozen-string-literal: true

require_dependency 'active_support/core_ext/module/delegation'

# Domain model object encapsulating a particular data view in the UI, based
# around a particular theme group of indicators in the cube. For example,
# a view of the  `averagePrice` indicator, together with the relevant dates,
# location and other options, and access to the underlying data, to enable
# the renderer to draw the display
# rubocop:disable Metrics/ClassLength
class DataView
  include Rails.application.routes.url_helpers

  attr_reader :user_selections
  attr_reader :query_result
  attr_reader :indicator
  attr_reader :theme
  attr_accessor :first

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
    columns = as_table_columns
    data = project_data(query_result, columns)
    { columns: columns, data: data }
  end

  # @return A Hash of the attributes needed to convey the key parameters of
  # this data view to JavaScript code
  def as_js_attributes
    {
      indicator: indicator.to_json,
      theme: theme_with_labels.to_json,
      location: Locations.lookup_location(selected_location).to_json,
      from_date: { date: user_selections.from_date }.to_json,
      to_date: { date: user_selections.to_date }.to_json,
      first: first ? 'true' : nil
    }
  end

  # @return A node ID for this data view, identifying the indicator and theme
  def node_id
    "#{indicator ? "#{indicator.slug}-" : ''}#{theme.slug}".tr('_', '-')
  end

  private

  def title_with_indicator
    change_path = edit_browse_path(user_selections.params)
    <<~TITLE
      #{I18n.t(indicator.label_key)}
      for <a href='#{change_path}' class='o-data-view__location'>#{location.label},</a>
      by #{I18n.t(title_key).downcase}
    TITLE
      .html_safe
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

  def as_table_columns
    [{ label: 'Date', pred: 'ukhpi:refMonth' }] +
      theme.statistics.map do |statistic|
        if statistic_selected?(statistic)
          { label: I18n.t(statistic.label_key), pred: pred_name(statistic) }
        end
      end .compact
  end

  def pred_name(statistic)
    "ukhpi:#{indicator_name(indicator)}#{statistic_name(statistic)}"
  end

  def indicator_name(indicator)
    indicator&.root_name
  end

  def statistic_name(statistic)
    statistic.root_name
  end

  def project_data(query_result, columns)
    query_result.map do |row_data|
      columns.map do |column|
        datum = row_data[column[:pred]]
        datum = datum.is_a?(Hash) ? datum['@value'] : datum
        datum.is_a?(Array) && datum.length == 1 ? datum.first : datum
      end
    end
  end

  def theme_with_labels
    twl = theme.dup

    stats = theme.statistics.map do |statistic|
      stat_h = statistic.to_h
      stat_h[:label] = I18n.t(statistic.label_key)
      stat_h[:selected] = user_selections.selected_statistics.include?(statistic.slug)
      stat_h
    end

    twl.statistics = stats
    twl
  end

  def location
    Regions.lookup_region(user_selections.selected_location)
  end
end
