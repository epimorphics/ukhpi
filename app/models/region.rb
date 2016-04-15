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
    @labels.any? {|key, label| key == lang && label.include?( name )} && type == rtype
  end

  def label( lang = :en )
    @labels[lang]
  end
end
