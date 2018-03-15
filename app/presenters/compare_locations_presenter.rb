# frozen-string-literal: true

require_dependency 'active_support/core_ext/module/delegation'

# Presenter class that encapsulates the behaviour of mapping the user-selections
# to side-by-side comparisons for different areas
class CompareLocationsPresenter # rubocop:disable Metrics/ClassLength
  include I18n
  include LocationsTable

  attr_reader :user_compare_selections
  attr_reader :query_results

  def initialize(user_compare_selections, query_results)
    @user_compare_selections = user_compare_selections
    @query_results = query_results
  end

  delegate :selected_indicator, to: :user_compare_selections
  delegate :selected_statistic, to: :user_compare_selections
  delegate :from_date, to: :user_compare_selections
  delegate :to_date, to: :user_compare_selections
  delegate :search_term, to: :user_compare_selections
  delegate :'search?', to: :user_compare_selections
  delegate :as_json, to: :user_compare_selections
  delegate :selected_locations, to: :user_compare_selections

  def headline_summary
    ind = I18n.t(indicator.slug)
    stat = I18n.t(statistic.label_key).downcase
    from = user_compare_selections.from_date.strftime('%b %Y')
    to = user_compare_selections.to_date.strftime('%b %Y')

    "<strong>#{ind}</strong> for <strong>#{stat}</strong>, #{from} to #{to}".html_safe
  end

  def locations_summary
    if (1..2).cover?(selected_locations.length)
      selected_locations.map(&:label).join(' and ')
    else
      "#{selected_locations.length} locations"
    end
  end

  def without_location(location)
    user_compare_selections.without('location', location.gss).to_h
  end

  def with_statistic(statistic, indicator)
    with_stat = user_compare_selections.with('st', statistic.slug)
    if indicator
      with_stat.with('in', indicator.slug)
    else
      with_stat.without('in', user_compare_selections.selected_indicator)
    end .to_h
  end

  def statistic_indicator_choices # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    rows = []

    ukhpi.themes.each_value do |theme|
      if theme.slug == 'volume'
        theme.statistics.each { |stat| rows << [stat, [nil, nil, nil, nil, [stat, nil]]] }
      else
        theme.statistics.each do |stat|
          row = ukhpi.indicators.map { |indic| [stat, indic] }
          rows << [stat, row + [nil]]
        end
      end
    end

    rows
  end

  def current_selection?(stat, indicator)
    (stat.slug == user_compare_selections.selected_statistic) &&
      (!indicator || indicator.slug == user_compare_selections.selected_indicator)
  end

  def query_results_rows # rubocop:disable Metrics/AbcSize
    data_by_columns = query_results.keys.sort.map do |location_name|
      query_results[location_name]
    end

    pred = selected_statistic_uri

    data_by_columns.transpose.map do |row|
      [period_date(row.first)] + (row.map { |values| values.fetch(pred, nil)&.first })
    end
  end

  def search_results
    return nil unless search_term&.length&.>(1)

    @search_results ||= locations.values.select do |location|
      location.matches_name?(search_term, nil)
    end
  end

  def with_location(location)
    user_compare_selections
      .with('location[]', location.gss)
      .without('location-term')
      .without('form-action')
      .to_h
  end

  def format(val)
    ValueFormatter.format(val,
                          slug: indicator.label,
                          template: "<div class='u-text-right'>%<formatted>s</div>")
  end

  def indicator
    selected = user_compare_selections.selected_indicator
    ukhpi.indicators.find { |indic| indic.slug == selected }
  end

  def unavailable_statistic_indicator?
    if indicator.volume? && !statistic.volume?
      "We're sorry, #{indicator.label.downcase} is not available for #{statistic.label}."
    else
      false
    end
  end

  private

  def statistic
    selected = user_compare_selections.selected_statistic
    found = nil

    ukhpi.themes.find do |_theme_id, theme|
      theme.statistics.find do |stat|
        found = stat if stat.slug == selected
      end
    end

    found
  end

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end

  def selected_statistic_uri
    "ukhpi:#{indicator&.root_name}#{statistic&.root_name}"
  end

  def period_date(row)
    raw_date = row['ukhpi:refMonth']['@value']
    ValueFormatter.month_year(raw_date)
  end
end
