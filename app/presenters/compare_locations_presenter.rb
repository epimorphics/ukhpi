# frozen-string-literal: true

# Presenter class that encapsulates the behaviour of mapping the user-selections
# to side-by-side comparisons for different areas
class CompareLocationsPresenter
  include I18n
  attr_reader :user_compare_selections

  def initialize(user_compare_selections)
    @user_compare_selections = user_compare_selections
  end

  def headline_summary
    ind = I18n.t(indicator.slug).downcase
    stat = I18n.t(statistic.label_key).downcase
    from = user_compare_selections.from_date.strftime('%b %Y')
    to = user_compare_selections.to_date.strftime('%b %Y')
    "Comparing #{ind} for #{stat}, #{from} to #{to}"
  end

  def selected_locations
    user_compare_selections.selected_locations.map do |location_id|
      Regions.lookup_gss(location_id)
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

  private

  def indicator
    selected = user_compare_selections.selected_indicator
    ukhpi.indicators.find { |indic| indic.slug == selected }
  end

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
end
