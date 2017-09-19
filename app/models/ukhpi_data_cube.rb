# frozen_string_literal: true

# An encapsulation of the DSD denoting the RDF cube data model for UKHPI
class UkhpiDataCube
  include CubeDataModel::Vocabularies

  CONFIG_DIR = 'dsapi'
  DSD_FILE = 'UKHPI-dsd.ttl'

  attr_reader :dsd

  def initialize
    @dsd = CubeDataModel::DSD.new(load_model, UKHPI.datasetDefinition)
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
