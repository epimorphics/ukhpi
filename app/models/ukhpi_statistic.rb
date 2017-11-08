# frozen-string-literal: true

# Encapsulates an individual statistic within the UKHPI dataset, for example
# 'detached houses'. Statistics are matched with indicators, such as average
# price or percentage annual change to denote measures in the statistical
# data cube.
class UkhpiStatistic
  attr_reader :slug
  attr_reader :root_name
  attr_reader :label_key

  def initialize(slug, root_name, label_key, volume)
    @slug = slug
    @root_name = root_name
    @label_key = label_key
    @volume = volume
  end

  # @return True if this statistic has a volume indicator
  def volume?
    @volume
  end

  # @return The label for this statistic
  def label
    I18n.t(label_key)
  end

  # @return True if this statistic is selected in the user selections
  def selected?(user_selections)
    user_selections.selected_statistics.include?(slug)
  end

  # @return The state of this statistic, serialised to a Hash
  def to_h(user_selections)
    {
      slug: slug,
      rootName: root_name,
      label: label,
      hasVolume: volume?,
      isSelected: selected?(user_selections)
    }
  end
end
