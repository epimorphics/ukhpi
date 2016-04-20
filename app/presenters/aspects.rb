# Presenter for managing which measures of the cube are presented as aspects,
# according to the current user preferences

class Aspects
  attr_reader :prefs

  DEFAULT_ASPECTS = %i( hpi ap pmc pac )

  def initialize( prefs )
    @prefs = prefs
    @aspects = all_measures.reduce( Hash.new ) do |hash, measure|
      hash[measure.slug.to_sym] = measure
      hash
    end
  end

  def visible_aspects
    prefs.aspects || DEFAULT_ASPECTS
  end

  def aspect( slug )
    @aspects[slug]
  end

  :private

  def all_measures
    DataModel.new.measures
  end
end
