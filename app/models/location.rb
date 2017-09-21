# frozen_string_literal: true

# Encapsulates a single location where UKHPI observations can be made. Locations
# may be countries or European regions, local authorities, or counties or
# regions of England
class Location
  attr_reader :uri, :type, :parent, :gss

  def initialize(uri, labels, type, parent, gss)
    @uri = uri
    @labels = labels
    @type = type
    @parent = parent
    @gss = gss
  end

  def matches_name?(name, rdf_types, lang = :en)
    rdf_type?(rdf_types) &&
      @labels.any? do |key, label|
        key == lang &&
          label.downcase.include?(name.downcase)
      end
  end

  def rdf_type?(rdf_types)
    rdf_types.nil? || rdf_types.empty? || rdf_types.include?(type)
  end

  def label(lang = :en)
    @labels[lang]
  end

  def <=>(other_region, lang = :en)
    label(lang) <=> other_region.label(lang)
  end

  def gss?(gss)
    @gss == gss
  end
end
