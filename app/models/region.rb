# Encapsulates a single regiong where UKHPI observations can be made

class Region
  attr_reader :uri, :type, :parent, :gss

  def initialize( uri, labels, type, parent, gss )
    @uri = uri
    @labels = labels
    @type = type
    @parent = parent
    @gss = gss
  end

  def matches_name?( name, rtype, lang = :en )
    is_of_type?( rtype ) &&
    @labels.any? do |key, label|
      key == lang &&
      label.downcase.include?( name.downcase )
    end
  end

  def is_of_type?( rtype )
    !rtype || type == rtype
  end

  def label( lang = :en )
    @labels[lang]
  end

  def <=>( other_region, lang = :en )
    label( lang ) <=> other_region.label( lang )
  end

  def is_gss?( gss )
    @gss == gss
  end
end
