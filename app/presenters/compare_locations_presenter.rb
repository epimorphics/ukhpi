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
