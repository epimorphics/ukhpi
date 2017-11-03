# frozen-string-literal: true

# Decorator for query results that provides additional capabilities for
# presenting data in downloadable form
class DownloadPresenter
  include DownloadFormatter

  attr_reader :query_command

  def initialize(query_command)
    @query_command = query_command
  end

  # @return an Array of the column names for the selected columns in
  # this download. Will include the fixed columns, plus variables columns
  # derived from the currently selected themes and indicators
  def column_names
    fixed_labels = FIXED_COLUMNS.map { |c| c[:label] }
    selected_labels = map_user_selectable_columns do |ind_stat|
      ind_key = ind_stat[:ind]&.slug
      stat_key = ind_stat[:stat].label_key

      ind_key ? "#{I18n.t(ind_key)} #{I18n.t(stat_key)}" : I18n.t(stat_key)
    end

    (fixed_labels + selected_labels).map { |label| "\"#{label}\"" }
  end

  private

  # Map the given block over the selected columns
  def map_user_selectable_columns(&block)
    user_selectable_columns.map(&block)
  end

  # @return An Array of the selected indicator-statistic pairs that are selected
  # in the current user selections
  def user_selectable_columns
    @user_selectable_columns ||=
      selected_themes
      .map(&:statistics)
      .flatten
      .map(&method(:statistic_with_indicators))
      .flatten
  end

  # @return An array of the given statistic paired with the currently selected
  # indicators
  def statistic_with_indicators(stat)
    indicators = accepts_indicators?(stat) ? selected_indicators : [nil]
    indicators.map { |ind| indicator_statistic_pair(ind, stat) }
  end

  def indicator_statistic_pair(ind, stat)
    { ind: ukhpi.indicator(ind), stat: stat }
  end

  def selected_indicators
    query_command.user_selections.selected_indicators
  end

  # @return True if the given statistic is one that is modified by adding one
  # of the indicators, such as house price index or average price
  def accepts_indicators?(stat)
    stat.root_name !~ /salesVolume/
  end

  # @return An array of the currently selected themes from the user selections
  def selected_themes
    return @selected_themes if @selected_themes

    themes = query_command.user_selections.params['thm'] || all_themes
    @selected_themes = themes.map { |theme_slug| ukhpi.theme(theme_slug) }
  end

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end

  def all_themes
    ukhpi.themes.map(&:slug)
  end
end
