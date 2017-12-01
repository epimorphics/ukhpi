# frozen_string_literal: true

# Unit tests on the DataModel class and helpers

require 'test_helper'

class DataModelTest < ActiveSupport::TestCase
  let(:cube) { UkhpiDataCube.new }

  it 'should load the DSD' do
    cube.dsd.graph.wont_be_nil
  end

  it 'should list the components' do
    cube.dsd.components.count.must_be :>=, 49
  end

  it 'should retrieve the labels for each compoonent' do
    labels = cube.dsd.measures.map(&:label)
    labels.must_include 'Average price'
  end

  it 'should retrieve the comments for each component' do
    comments = cube.dsd.measures.map(&:comment)
    comments.must_include('The percentage change in the average house price compared to the same period twelve months earlier.') # rubocop:disable Metrics/LineLength
  end

  it 'should separate out the dimensions' do
    cube.dsd.dimensions.count.must_equal 2
  end

  it 'should separate out the measures' do
    cube.dsd.measures.count.must_be :>=, 47
  end

  it 'should produce a unique slug for each measure' do
    slugs = cube.dsd.measures.map(&:slug)
    slugs.must_include 'apsd'
    slugs.uniq.length.must_equal slugs.length
  end

  it 'should produce a qname for each measure' do
    slugs = cube.dsd.measures.map(&:qname)
    slugs.must_include 'ukhpi:averagePriceSemiDetached'
    slugs.uniq.length.must_equal slugs.length
  end

  describe '#themes' do
    it 'should return a Hash of the themes' do
      cube.themes.keys.length.must_be :>=, 4
      cube.themes.keys.first.must_equal :property_type
    end
  end

  describe '#theme' do
    it 'should return a theme object' do
      cube.theme(:property_type).statistics.first.slug.must_equal 'all'
    end
  end

  describe '#each_theme' do
    it 'should iterate over the themes' do
      arr = []
      cube.each_theme { |_theme_key, theme| arr << theme.is_a?(UkhpiTheme) }
      arr.length.must_be :>=, 4
      arr.wont_include false
    end
  end
end
