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
    fixed_labels = FIXED_COLUMNS.map { |c| c[:label] }
    selected_labels = map_user_selectable_columns do |ind_stat|
      ind_key = ind_stat[:ind]&.slug
      stat_key = ind_stat[:stat].label_key

      ind_key ? "#{I18n.t(ind_key)} #{I18n.t(stat_key)}" : I18n.t(stat_key)
    end

    (fixed_labels + selected_labels).map { |label| "\"#{label}\"" }
  end

  # @return An array of rows of data matching the selected columns
  def rows
    row_preds = row_predicates
    static_values = static_row_values

    results.map do |result|
      as_row(result, static_values, row_preds)
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
        byebug unless @results && query_command.results
        @results.concat(query_command.results)
      end

      # TODO will need to sort this list as well
    end

    @results
  end

  private

  # @return An array of the predicates used to project a result to a download row
  def row_predicates
    fixed_predicates = FIXED_COLUMNS.map { |c| c[:pred] }
    selected_predicates = map_user_selectable_columns do |ind_stat|
      "ukhpi:#{ind_stat[:ind]&.root_name}#{ind_stat[:stat].root_name}"
    end

    fixed_predicates + selected_predicates
  end

  # @return A map of values that do not change from row to row
  def static_row_values
    sample_row = results&.first
    return {} unless sample_row

    {
      'static:regionName' => location_name(sample_row),
      'static:regionURI' => location_uri(sample_row),
      'static:regionGSS' => location_gss(sample_row),
      'static:reportingPeriod' => reporting_period_label(sample_row)
    }
  end

  # Given an array of predicates, a result and some static data return a single
  # row of the download that contains just the results matching the predicates.
  def as_row(result, static_values, preds)
    preds.map { |pred| format_value(result[pred] || static_values[pred]) }
  end

  def format_value(val)
    v = val

    if v.is_a?(Hash)
      v = v['@value'] if v['@value']
      v = v['@id'] if v['@id']
    end

    v
  end

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
    user_selections.selected_indicators
  end

  # @return True if the given statistic is one that is modified by adding one
  # of the indicators, such as house price index or average price
  def accepts_indicators?(stat)
    stat.root_name !~ /salesVolume/
  end

  # @return An array of the currently selected themes from the user selections
  def selected_themes
    return @selected_themes if @selected_themes

    themes = user_selections.params['thm'] || all_themes
    @selected_themes = themes.map { |theme_slug| ukhpi.theme(theme_slug) }
  end

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end

  def all_themes
    ukhpi.themes.values.map(&:slug)
  end
end
