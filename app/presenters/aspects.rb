# Presenter for managing which measures of the cube are presented as aspects,
# according to the current user preferences

Struct.new( "AspectGroup", :label, :"advanced?", :measures )

class Aspects
  attr_reader :prefs

  MEASURE_GROUP_ROOTS = [
    {root: "",                    label: "overall_indices",          advanced: false},
    {root: "Detached",            label: "detached_houses"    ,      advanced: false},
    {root: "SemiDetached",        label: "semi_detached_houses",     advanced: false},
    {root: "Terraced",            label: "terraced_houses",          advanced: false},
    {root: "FlatMaisonette",      label: "flats_and_maisonettes",    advanced: false},
    {root: "NewBuild",            label: "new_build",                advanced: false},
    {root: "ExistingProperty",    label: "existing_properties",      advanced: false},
    {root: "Cash",                label: "cash_purchases",           advanced: true},
    {root: "Mortgage",            label: "mortgage_purchases",       advanced: true},
    {root: "FirstTimeBuyer",      label: "first_time_buyers",        advanced: true},
    {root: "FormerOwnerOccupier", label: "former_owner_occupiers",   advanced: true}
  ]

  INDICES = %w( housePriceIndex averagePrice percentageMonthlyChange percentageAnnualChange )

  INDEX_LABELS = INDICES.map do |ind|
    ind
      .underscore
      .gsub( /_/, " " )
      .gsub( "house price ", "" )
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
        I18n.t( "aspect.#{grouping[:label]}" ),
        grouping[:advanced],
        INDEX_LABELS.zip( inds )
      )
    end
  end

  def visible?( aspect )
    prefs.aspects.find {|a| a == aspect.slug.to_sym}
  end

  :private

  def all_measures
    @all_measures ||= DataModel.new.measures
  end

  def measure_from_qname( qname )
    all_measures.find {|m| m.qname == qname}
  end

  def lookup_measure( ind, root )
    qname = "ukhpi:#{ind}#{root}"
    measure_from_qname( qname )
  end
end
