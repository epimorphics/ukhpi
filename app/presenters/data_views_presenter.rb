# frozen-string-literal: true

# Presenter object that calculates the set of `DataView`s that should be
# created from a given `UserSelection`.
class DataViewsPresenter
  attr_reader :user_selections
  attr_reader :query_result

  def initialize(user_selections, query_result)
    @user_selections = user_selections
    @query_result = query_result
  end

  def data_views
    @data_views ||= (qualified_data_views + non_qualified_data_views).flatten
  end

  def to_json(_options = {})
    JSON.dump(
      results: query_result,
      selections: data_views.first.as_js_attributes
    )
  end

  def each_theme_with_views(&block) # rubocop:disable Metrics/MethodLength
    first = true

    qualified_themes.each do |theme_name|
      theme = ukhpi.theme(theme_name)
      data_views = as_data_views(ukhpi.indicators, theme, first)
      first = false

      block.yield(theme, data_views)
    end

    non_qualified_themes.each do |theme_name|
      theme = ukhpi.theme(theme_name)
      block.yield(theme, as_data_views([nil], theme, false))
    end
  end

  private

  # @return An array of the data views that are qualified by indicators
  def qualified_data_views
    qualified_themes.map do |theme_name|
      as_data_views(ukhpi.indicators, ukhpi.theme(theme_name), true)
    end
  end

  # @return An array of the data views that are not qualified by indicators
  def non_qualified_data_views
    non_qualified_themes.map do |theme_name|
      as_data_views([nil], ukhpi.theme(theme_name), false)
    end
  end

  # @return An array of data view objects
  def as_data_views(indicators, theme, is_first)
    data_views = indicators.map do |indicator|
      DataView.new(user_selections: user_selections, query_result: query_result,
                   indicator: indicator, theme: theme)
    end

    data_views.first.first = is_first
    data_views
  end

  # @return An arry of the UKHPI statistics themes (e.g. property type) that *do* get
  # qualified by the UKHPI indicators (e.g. `index`, `averagePrice`)
  def qualified_themes
    ukhpi.themes.keys - non_qualified_themes
  end

  # @return An arry of the UKHPI statistics themes (e.g. sales volume) that *do not* get
  # qualified by the UKHPI indicators (e.g. `index`, `averagePrice`)
  def non_qualified_themes
    [:volume]
  end

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end
end
