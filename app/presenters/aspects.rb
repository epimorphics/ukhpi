# frozen_string_literal: true

# Presenter for managing which measures of the cube are presented as aspects,
# according to the current user preferences
class Aspects
  attr_reader :prefs

  CATEGORIES = [
    { root: '',                        label: 'all_property_types', advanced: false },
    { root: 'Detached',                label: 'detached_houses', advanced: false },
    { root: 'SemiDetached',            label: 'semi_detached_houses',     advanced: false },
    { root: 'Terraced',                label: 'terraced_houses',          advanced: false },
    { root: 'FlatMaisonette',          label: 'flats_and_maisonettes',    advanced: false },
    { root: 'NewBuild',                label: 'new_build',                advanced: true },
    { root: 'ExistingProperty',        label: 'existing_properties',      advanced: true },
    { root: 'Cash',                    label: 'cash_purchases',           advanced: true },
    { root: 'Mortgage',                label: 'mortgage_purchases',       advanced: true },
    { root: 'FirstTimeBuyer',          label: 'first_time_buyers',        advanced: true },
    { root: 'FormerOwnerOccupier',     label: 'former_owner_occupiers',   advanced: true }
  ].freeze

  INDICATORS = [
    { root: 'housePriceIndex',         label: 'house_price_index' },
    { root: 'averagePrice',            label: 'average_price' },
    { root: 'percentageChange',        label: 'percentage_monthly_change' },
    { root: 'percentageAnnualChange',  label: 'percentage_annual_change' }
  ].freeze

  COMMON_STATS = [
    { root: 'salesVolume',             label: 'sales_volume' }
  ].freeze

  def initialize(prefs)
    @prefs = prefs
    @aspects = all_measures.each_with_object({}) do |measure, hash|
      hash[measure.local_name.to_sym] = measure
    end
  end

  def visible_aspects
    prefs.aspect_indicators.product(prefs.aspect_categories).map do |pair|
      "#{pair.first}#{pair.second}".to_sym
    end
  end

  def aspect(name)
    @aspects[name]
  end

  def each(&block)
    @aspects.values.each(&block)
  end

  def visible?(aspect)
    prefs.aspects.find { |a| a == aspect.slug.to_sym }
  end

  private

  def all_measures
    @all_measures ||= DataModel.new.measures
  end

  def measure_from_qname(qname)
    all_measures.find { |m| m.qname == qname }
  end

  def lookup_measure(ind, root)
    qname = "ukhpi:#{ind}#{root}"
    measure_from_qname(qname)
  end
end
