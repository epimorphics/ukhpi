# frozen_string_literal: true

# An encapsulation of the DSD denoting the RDF cube data model for UKHPI
class UkhpiDataCube
  include CubeDataModel::Vocabularies

  CONFIG_DIR = 'dsapi'
  DSD_FILE = 'UKHPI-dsd.ttl'

  # rubocop:disable Layout/IndentArray
  THEMES = {
    property_type: UkhpiTheme.new('property_type', [
      UkhpiStatistic.new('all', '',               'all_property_types', true),
      UkhpiStatistic.new('det', 'Detached',       'detached_houses', false),
      UkhpiStatistic.new('sem', 'SemiDetached',   'semi_detached_houses', false),
      UkhpiStatistic.new('ter', 'Terraced',       'terraced_houses', false),
      UkhpiStatistic.new('fla', 'FlatMaisonette', 'flats_and_maisonettes', false)
    ]),

    buyer_status: UkhpiTheme.new('buyer_status', [
      UkhpiStatistic.new('ftb', 'FirstTimeBuyer',      'first_time_buyers', false),
      UkhpiStatistic.new('foo', 'FormerOwnerOccupier', 'former_owner_occupiers', false)
    ]),

    funding_status: UkhpiTheme.new('funding_status', [
      UkhpiStatistic.new('cas', 'Cash',     'cash_purchases', true),
      UkhpiStatistic.new('mor', 'Mortgage', 'mortgage_purchases', true)
    ]),

    property_status: UkhpiTheme.new('property_status', [
      UkhpiStatistic.new('new', 'NewBuild',         'new_build', true),
      UkhpiStatistic.new('exi', 'ExistingProperty', 'existing_properties', true)
    ])
  }.freeze

  INDICATORS =
    [
      UkhpiIndicator.new('avg', 'averagePrice',           'average_price'),
      UkhpiIndicator.new('pac', 'percentageAnnualChange', 'percentage_annual_change'),
      UkhpiIndicator.new('pmc', 'percentageChange',       'percentage_monthly_change'),
      UkhpiIndicator.new('hpi', 'housePriceIndex',        'house_price_index'),
      UkhpiIndicator.new('vol', 'salesVolume',            'sales_volume')
    ].freeze
  # rubocop:enable Layout/IndentArray

  attr_reader :dsd

  def initialize
    @dsd = CubeDataModel::DSD.new(load_model, UKHPI.datasetDefinition)
  end

  # @return The themes which are used to group statistics into logical units
  def themes
    THEMES
  end

  # @return A given theme, useful for grouping statistics into logical units
  def theme(theme_name)
    themes[theme_name.to_sym]
  end

  # Invoke a block with the key and members for each theme of statistics
  def each_theme(&block)
    THEMES.each(&block)
  end

  # @return An array of the indicators
  def indicators
    INDICATORS
  end

  # @return A given indicator by name
  def indicator(slug)
    indicators.find { |ind| ind.slug == slug }
  end

  # @return A given statistic by name
  def statistic(slug)
    statistics.find { |stat| stat.slug == slug }
  end

  # @return A flat array of all statistics
  def statistics
    THEMES.values.map(&:statistics).flatten
  end

  # Invoke a block with each indicator as an argument
  def each_indicator(&block)
    indicators.each(&block)
  end

  # @return The elements of the data-cube properties (and thus also DSAPI aspects)
  # corresponding to the indicator
  def indicator_elements
    ELEMENTS.indicators
  end

  # @return The elements of the data-cube properties (and thus also DSAPI aspects)
  # corresponding to the non-property-type statistics
  def non_property_type_indicator_elements
    ELEMENTS.non_property_type_indicators
  end

  private

  def load_model
    read_data_model unless defined?(@@model)
    @@model
  end

  def read_data_model
    file = File.join(Rails.root, 'config', CONFIG_DIR, DSD_FILE)
    @@model = RDF::Graph.load(file, format: :ttl) # rubocop:disable Style/ClassVars
  end
end
