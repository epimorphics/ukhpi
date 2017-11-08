# frozen-string-literal: true

# Encapsulates a theme of UKHPI statistics, which are natural groupings of the
# various statistics in the overall dataset. Example themes include
# 'property type' and 'buyer status'
class UkhpiTheme
  attr_reader :slug
  attr_reader :statistics

  def initialize(slug, statistics)
    @slug = slug
    @statistics = statistics
  end

  # The indicators that are appropriate to the set of statistics in
  # this theme. In particular, if none of this theme's statistics admit a
  # volume indicator, then don't include the volume indicator in the return.
  # @return Array of theme-appropriate indicators
  def indicators
    inds = UkhpiDataCube::INDICATORS.dup

    includes_volume? ? inds : inds.reject(&:volume?)
  end

  # @return The label for this theme
  def label
    I18n.t(slug)
  end

  # @return The state of this theme, serialised to a Hash
  def to_h(user_selections)
    {
      slug: slug,
      label: label,
      indicators: indicators,
      statistics: statistics.map { |stat| stat.to_h(user_selections) }
    }
  end

  private

  # @return True if at least one statistic admits the sales volume indicator
  def includes_volume?
    statistics.reduce(false) do |memo, stat|
      memo || stat.volume?
    end
  end
end
