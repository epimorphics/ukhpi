# frozen-string-literal: true

# Decorator for query results that provides additional capabilities for
# presenting data in downloadable form
class DownloadPresenter
  include DownloadFormatter

  attr_reader :query_commands

  def initialize(query_commands)
    @query_commands = query_commands.is_a?(Array) ? query_commands : [query_commands]
  end

  # @return an Array of the column names for the selected columns in
  # this download. Will include the fixed columns, plus variables columns
  # derived from the currently selected themes and indicators
  def column_names
    columns.map { |column| "\"#{column.label}\"" }
  end

  # @return An array of rows of data matching the selected columns
  def rows
    results.map do |result|
      as_row(result, columns)
    end
  end

  # @return The embedded user selections
  def user_selections
    query_commands.first.user_selections
  end

  # @return The embedded results
  def results
    unless @results
      @results = []

      query_commands.each do |query_command|
        query_command.perform_query unless query_command.results
        @results.concat(query_command.results)
      end

      sort_results_by_date_and_location
    end

    @results
  end

  private

  def columns
    @columns ||= FIXED_COLUMNS + user_selection_columns
  end

  def user_selection_columns
    statistics = theme_selected? ? theme_statistics : selected_statistics
    statistics.map(&method(:statistic_indicator_columns)).flatten
  end

  # Given an array of predicates, a result and some static data return a single
  # row of the download that contains just the results matching the predicates.
  def as_row(result, columns)
    columns.map { |column| column.format_value(result) }
  end

  # @return An Array of the selected statistics that are selected
  # in the current user-selected theme
  def theme_statistics
    selected_themes.map(&:statistics).flatten
  end

  # @return An array of the given statistic paired with the currently selected
  # indicators
  def statistic_indicator_columns(stat)
    selected_indicators.map do |ind|
      DownloadColumn.new(
        ind: ind,
        stat: stat,
        pred: "ukhpi:#{ind&.root_name}#{stat.root_name}"
      )
    end
  end

  # Return truthy if the user selections include a named theme
  def theme_selected?
    user_selections.params['thm']
  end

  # @return An array of the currently selected themes from the user selections
  def selected_themes
    return @selected_themes if @selected_themes

    themes = theme_selected? || all_themes
    @selected_themes = themes.map { |theme_slug| ukhpi.theme(theme_slug) }
  end

  def selected_statistics
    user_selections.selected_statistics.map do |slug|
      ukhpi.statistic(slug)
    end
  end

  def selected_indicators
    user_selections.selected_indicators.map do |slug|
      ukhpi.indicator(slug)
    end
  end

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end

  def all_themes
    ukhpi.themes.values.map(&:slug)
  end

  # rubocop:disable Metrics/MethodLength
  def sort_results_by_date_and_location
    @results.sort! do |result0, result1|
      date0 = result0['ukhpi:refMonth']['@value']
      date1 = result1['ukhpi:refMonth']['@value']
      location0 = result0['ukhpi:refRegion']['@id']
      location1 = result1['ukhpi:refRegion']['@id']

      if date0 == date1
        location0 <=> location1
      else
        date0 <=> date1
      end
    end
  end
end
