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
    @labels.any? {|key, label| key == lang && label.include?( name )}
  end

  def is_of_type?( rtype )
    !rtype || type == rtype
  end

  def label( lang = :en )
    @labels[lang]
  end
end
