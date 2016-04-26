# Presenter for managing which measures of the cube are presented as aspects,
# according to the current user preferences

Struct.new( "AspectGroup", :label, :"advanced?", :measures )

class Aspects
  attr_reader :prefs

  MEASURE_GROUP_ROOTS = [
    {root: "",                    label: "overall indices",          advanced: false},
    {root: "Detached",            label: "detached properties",      advanced: false},
    {root: "SemiDetached",        label: "semi-detached properties", advanced: false},
    {root: "Terraced",            label: "terraced houses",          advanced: false},
    {root: "FlatMaisonette",      label: "flats and maisonettes",    advanced: false},
    {root: "NewBuild",            label: "new build",                advanced: false},
    {root: "ExistingProperty",    label: "existing properties",      advanced: false},
    {root: "Cash",                label: "cash purchases",           advanced: true},
    {root: "Mortgage",            label: "mortgage purchases",       advanced: true},
    {root: "FirstTimeBuyer",      label: "first-time buyers",        advanced: true},
    {root: "FormerOwnerOccupier", label: "former owner-occupiers",   advanced: true}
  ]

  INDICES = %w( index averagePrice percentageMonthlyChange percentageAnnualChange )

  INDEX_LABELS = INDICES.map do |ind|
    ind
      .underscore
      .gsub( /_/, " " )
      .gsub( "percentage ", "" )
  end

  def initialize( prefs )
    @prefs = prefs
    @aspects = all_measures.reduce( Hash.new ) do |hash, measure|
      hash[measure.slug.to_sym] = measure
      hash
    end
  end

  def visible_aspects
    prefs.aspects
  end

  def aspect( slug )
    @aspects[slug]
  end

  def each( &block )
    @aspects.values.each( &block )
  end

  def aspect_groups
    MEASURE_GROUP_ROOTS.map do |grouping|
      inds =INDICES.map {|ind| lookup_measure( ind, grouping[:root] )}

      Struct::AspectGroup.new(
        grouping[:label],
        grouping[:advanced],
        INDEX_LABELS.zip( inds )
      )
    end
  end

  :private

  def all_measures
    @all_measures ||= DataModel.new.measures
  end

  def measure_from_qname( qname )
    all_measures.find {|m| m.qname == qname}
  end

  def lookup_measure( ind, root )
    if ind == "index" && root.empty?
      qname = "ukhpi:housePriceIndex"
    else
      qname = "ukhpi:#{ind}#{root}"
    end

    measure_from_qname( qname )
  end
end
