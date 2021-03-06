# frozen_string_literal: true

require 'test_helper'

# :nodoc:
class CubeComponentTest < ActiveSupport::TestCase
  let(:bNode0) { RDF::Node.new }
  let(:dimension) do
    g = RDF::Graph.new
    q = RDF::Resource.new('http://test.test/q')

    g << RDF::Statement(bNode0, CubeDataModel::Vocabularies::QB.dimension, q)

    CubeDataModel::CubeComponent.new(g, bNode0)
  end

  let(:bNode1) { RDF::Node.new }
  let(:measure) do
    g = RDF::Graph.new
    q = RDF::Resource.new('http://test.test/q')

    g << RDF::Statement(bNode1, CubeDataModel::Vocabularies::QB.measure, q)

    CubeDataModel::CubeComponent.new(g, bNode1)
  end

  describe 'CubeComponent' do
    it 'should return values for the "is-dimension?" and "is-measure?" test when asked' do
      _(dimension.dimension?).must_equal true
      _(dimension.measure?).must_equal false

      _(measure.dimension?).must_equal false
      _(measure.measure?).must_equal true
    end

    it 'should return a dimension on request' do
      _(dimension.dimension).must_be_kind_of CubeDataModel::CubeDimension
      _(measure.dimension).must_be_nil
    end

    it 'should return a measure on request' do
      _(dimension.measure).must_be_nil
      _(measure.measure).must_be_kind_of CubeDataModel::CubeMeasure
    end
  end
end
