# frozen_string_literal: true

# Encapsulates a single location where UKHPI observations can be made. Locations
# may be countries or European regions, local authorities, or counties or
# regions of England
class Location
  WALES = 'http://landregistry.data.gov.uk/id/region/wales'

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
    rdf_types.blank? || rdf_types.include?(type)
  end

  def label(lang = I18n.locale)
    @labels[lang] || @labels[:en]
  end

  def <=>(other_location, lang = :en)
    label(lang) <=> other_location.label(lang)
  end

  def gss?(gss)
    @gss == gss
  end

  # Return `true` if the location has a name in Welsh.
  # Rule out the Welsh name from display if it's letter-for-letter the
  # same as English. Strictly, the data should not contain such pairings,
  # but empirically we know that it does
  def welsh_name?
    @labels.key?(:cy) && (@labels.fetch(:cy) != @labels.fetch(:en))
  end

  def in_wales?
    [uri, parent].include?(WALES)
  end

  def to_h
    {
      uri: uri,
      labels: @labels,
      type: type,
      gss: gss
    }
  end
end
