# frozen_string_literal: true

require 'test_helper'

# :nodoc:
class CubeComponentTest < ActiveSupport::TestCase
  let(:b_node_0) { RDF::Node.new }
  let(:dimension) do
    g = RDF::Graph.new
    q = RDF::Resource.new('http://test.test/q')

    g << RDF::Statement(b_node_0, CubeDataModel::Vocabularies::QB.dimension, q)

    CubeDataModel::CubeComponent.new(g, b_node_0)
  end

  let(:b_node_1) { RDF::Node.new }
  let(:measure) do
    g = RDF::Graph.new
    q = RDF::Resource.new('http://test.test/q')

    g << RDF::Statement(b_node_1, CubeDataModel::Vocabularies::QB.measure, q)

    CubeDataModel::CubeComponent.new(g, b_node_1)
  end

  describe 'CubeComponent' do
    it 'should return values for the "is-dimension?" and "is-measure?" test when asked' do
      dimension.dimension?.must_equal true
      dimension.measure?.must_equal false

      measure.dimension?.must_equal false
      measure.measure?.must_equal true
    end

    it 'should return a dimension on request' do
      dimension.dimension.must_be_kind_of CubeDataModel::CubeDimension
      measure.dimension.must_be_nil
    end

    it 'should return a measure on request' do
      dimension.measure.must_be_nil
      measure.measure.must_be_kind_of CubeDataModel::CubeMeasure
    end
  end
end
