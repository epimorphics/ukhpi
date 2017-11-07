# frozen_string_literal: true

# An encapsulation of the DSD denoting the RDF cube data model for UKHPI
class UkhpiDataCube
  include CubeDataModel::Vocabularies

  CONFIG_DIR = 'dsapi'
  DSD_FILE = 'UKHPI-dsd.ttl'

  Struct.new('UkhpiTheme', :slug, :statistics)
  Struct.new('UkhpiStatistic', :slug, :root_name, :label_key)
  Struct.new('UkhpiIndicator', :slug, :root_name, :label_key)

  # rubocop:disable Layout/IndentArray
  THEMES = {
    property_type: Struct::UkhpiTheme.new('property_type', [
      Struct::UkhpiStatistic.new('all', '',               'all_property_types'),
      Struct::UkhpiStatistic.new('det', 'Detached',       'detached_houses'),
      Struct::UkhpiStatistic.new('sem', 'SemiDetached',   'semi_detached_houses'),
      Struct::UkhpiStatistic.new('ter', 'Terraced',       'terraced_houses'),
      Struct::UkhpiStatistic.new('fla', 'FlatMaisonette', 'flats_and_maisonettes')
    ]),

    ftb_foo: Struct::UkhpiTheme.new('ftb_foo', [
      Struct::UkhpiStatistic.new('ftb', 'FirstTimeBuyer',      'first_time_buyers'),
      Struct::UkhpiStatistic.new('foo', 'FormerOwnerOccupier', 'former_owner_occupiers')
    ]),

    cash_mortgage: Struct::UkhpiTheme.new('cash_mortgage', [
      Struct::UkhpiStatistic.new('cas', 'Cash',     'cash_purchases'),
      Struct::UkhpiStatistic.new('mor', 'Mortgage', 'mortgage_purchases')
    ]),

    new_existing: Struct::UkhpiTheme.new('new_existing', [
      Struct::UkhpiStatistic.new('new', 'NewBuild',         'new_build'),
      Struct::UkhpiStatistic.new('exi', 'ExistingProperty', 'existing_properties')
    ]),

    volume: Struct::UkhpiTheme.new('volume', [
      Struct::UkhpiStatistic.new('vol', 'salesVolume', 'sales_volume')
    ]),

    volume_funding_status: Struct::UkhpiTheme.new('volume_funding_status', [
      Struct::UkhpiStatistic.new('vcs', 'salesVolumeCash', 'sales_volume_cash'),
      Struct::UkhpiStatistic.new('vmg', 'salesVolumeMortgage', 'sales_volume_mortgage')
    ]),

    volume_property_status: Struct::UkhpiTheme.new('volume_property_status', [
      Struct::UkhpiStatistic.new('vnw', 'salesVolumeNewBuild', 'sales_volume_new_build'),
      Struct::UkhpiStatistic.new('vex', 'salesVolumeExistingProperty', 'sales_volume_existing')
    ])
  }.freeze

  INDICATORS =
    [
      Struct::UkhpiIndicator.new('hpi', 'housePriceIndex',        'house_price_index'),
      Struct::UkhpiIndicator.new('avg', 'averagePrice',           'average_price'),
      Struct::UkhpiIndicator.new('pmc', 'percentageChange',       'percentage_monthly_change'),
      Struct::UkhpiIndicator.new('pac', 'percentageAnnualChange', 'percentage_annual_change')
    ].freeze

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
