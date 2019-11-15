# frozen_string_literal: true

# Unit tests on the DataModel class and helpers

require 'test_helper'

class DataModelTest < ActiveSupport::TestCase
  let(:cube) { UkhpiDataCube.new }

  it 'should load the DSD' do
    _(cube.dsd.graph).wont_be_nil
  end

  it 'should list the components' do
    _(cube.dsd.components.count).must_be :>=, 49
  end

  it 'should retrieve the labels for each compoonent' do
    labels = cube.dsd.measures.map(&:label)
    _(labels).must_include 'Average price'
  end

  it 'should retrieve the comments for each component' do
    comments = cube.dsd.measures.map(&:comment)
    _(comments).must_include('The percentage change in the average house price compared to the same period twelve months earlier.')
  end

  it 'should separate out the dimensions' do
    _(cube.dsd.dimensions.count).must_equal 2
  end

  it 'should separate out the measures' do
    _(cube.dsd.measures.count).must_be :>=, 47
  end

  it 'should produce a unique slug for each measure' do
    slugs = cube.dsd.measures.map(&:slug)
    _(slugs).must_include 'apsd'
    _(slugs.uniq.length).must_equal slugs.length
  end

  it 'should produce a qname for each measure' do
    slugs = cube.dsd.measures.map(&:qname)
    _(slugs).must_include 'ukhpi:averagePriceSemiDetached'
    _(slugs.uniq.length).must_equal slugs.length
  end

  describe '#themes' do
    it 'should return a Hash of the themes' do
      _(cube.themes.keys.length).must_be :>=, 4
      _(cube.themes.keys.first).must_equal :property_type
    end
  end

  describe '#theme' do
    it 'should return a theme object' do
      _(cube.theme(:property_type).statistics.first.slug).must_equal 'all'
    end
  end

  describe '#each_theme' do
    it 'should iterate over the themes' do
      arr = []
      cube.each_theme { |_theme_key, theme| arr << theme.is_a?(UkhpiTheme) }
      _(arr.length).must_be :>=, 4
      _(arr).wont_include false
    end
  end
end
