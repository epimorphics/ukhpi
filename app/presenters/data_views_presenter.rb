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
    qualified_data_views + non_qualified_data_views
  end

  private

  def qualified_data_views
    as_data_views(qualified_themes)
  end

  def non_qualified_data_views
    themes = non_qualified_themes.map(&method(:as_theme))
    themes.map do |theme|
      DataView.new(user_selections: user_selections, query_result: query_result,
                   indicator: nil, theme: theme)
    end
  end

  def as_data_views(theme_names)
    themes = theme_names.map(&method(:as_theme))

    ukhpi.indicators.product(themes).map do |indicator, theme|
      DataView.new(user_selections: user_selections, query_result: query_result,
                   indicator: indicator, theme: theme)
    end
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

  def as_theme(theme_name)
    ukhpi.theme(theme_name)
  end
end
