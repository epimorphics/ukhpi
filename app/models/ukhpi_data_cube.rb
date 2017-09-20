# frozen_string_literal: true

# An encapsulation of the DSD denoting the RDF cube data model for UKHPI
class UkhpiDataCube
  include CubeDataModel::Vocabularies

  CONFIG_DIR = 'dsapi'
  DSD_FILE = 'UKHPI-dsd.ttl'

  Struct.new('DataCubeElements', :indicators, :property_types, :non_property_type_indicators)
  Struct.new('DataCubeElement', :root_name, :label_key)

  ELEMENTS = Struct::DataCubeElements.new(
    [
      Struct::DataCubeElement.new('',                    'all_property_types'),
      Struct::DataCubeElement.new('Detached',            'detached_houses'),
      Struct::DataCubeElement.new('SemiDetached',        'semi_detached_houses'),
      Struct::DataCubeElement.new('Terraced',            'terraced_houses'),
      Struct::DataCubeElement.new('FlatMaisonette',      'flats_and_maisonettes'),
      Struct::DataCubeElement.new('NewBuild',            'new_build'),
      Struct::DataCubeElement.new('ExistingProperty',    'existing_properties'),
      Struct::DataCubeElement.new('Cash',                'cash_purchases'),
      Struct::DataCubeElement.new('Mortgage',            'mortgage_purchases'),
      Struct::DataCubeElement.new('FirstTimeBuyer',      'first_time_buyers'),
      Struct::DataCubeElement.new('FormerOwnerOccupier', 'former_owner_occupiers')
    ],

    [
      Struct::DataCubeElement.new('housePriceIndex',        'house_price_index'),
      Struct::DataCubeElement.new('averagePrice',           'average_price'),
      Struct::DataCubeElement.new('percentageChange',       'percentage_monthly_change'),
      Struct::DataCubeElement.new('percentageAnnualChange', 'percentage_annual_change')
    ],

    [
      Struct::DataCubeElement.new('salesVolume', 'sales_volume')
    ]
  ).freeze

  attr_reader :dsd

  def initialize
    @dsd = CubeDataModel::DSD.new(load_model, UKHPI.datasetDefinition)
  end

  # @return The elements of the data-cube properties (and thus also DSAPI aspects)
  # corresponding to the property type
  def property_type_elements
    ELEMENTS.property_types
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
