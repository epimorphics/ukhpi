# frozen-string-literal: true

# Encapsulates an indicator for the various UKHPI statistics in the overall
# dataset. An indicator denotes a common characteristic across the statistics,
# such as 'average price' or 'percentage monthly change'. Indicators apply
# to statistics to denote measures in the UKHPI data cube. Not all inidicators
# apply to all statistics: there is no 'volume' indicator for property types
# other than 'all property types'.
class UkhpiIndicator
  attr_reader :slug, :root_name, :label_key

  def initialize(slug, root_name, label_key)
    @slug = slug
    @root_name = root_name
    @label_key = label_key
  end

  # @return True if this indicator denotes sales volume
  def volume?
    slug == 'vol'
  end

  # @return The label for this indicator
  def label
    I18n.t("indicator.#{label_key}")
  end

  # @return True if this indicator is selected in the given user selections
  def selected?(user_selections)
    user_selections.selected_indicators.include?(slug)
  end

  # @return The state of this indicator, serialised to a Hash
  def to_h(user_selections)
    {
      slug: slug,
      rootName: root_name,
      label: label,
      isVolume: volume?,
      isSelected: selected?(user_selections)
    }
  end
end
