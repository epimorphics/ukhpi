# frozen_string_literal: true

require 'test_helper'

# Unit tests on the DataModel class and helpers
class CubeResourceTest < ActiveSupport::TestCase
  let :resource do
    g = RDF::Graph.new
    r = RDF::Resource.new('http://test.test/testResource')
    q = RDF::Resource.new('http://test.test/q')

    g << RDF::Statement(r, RDF::RDFS.label, 'I am Groot')
    g << RDF::Statement(r, RDF::RDFS.comment, 'watch this!')
    g << RDF::Statement(r, RDF::RDFS.range, q)

    CubeDataModel::CubeResource.new(g, r)
  end

  describe 'CubeResource' do
    it 'should return the label' do
      _(resource.label).must_equal 'I am Groot'
    end

    it 'should return the comment' do
      _(resource.comment).must_equal 'watch this!'
    end

    it 'should return the range of the resource' do
      _(resource.range.to_s).must_equal 'http://test.test/q'
    end

    it 'should calculate a slug for the resource' do
      _(resource.slug).must_equal 'tr'
    end

    it 'should extract the local name' do
      _(resource.local_name).must_equal 'testResource'
    end

    it 'should return the URI' do
      _(resource.uri).must_equal 'http://test.test/testResource'
    end

    it 'should return the qname' do
      _(resource.qname).must_equal 'ukhpi:testResource'
    end
  end
end
