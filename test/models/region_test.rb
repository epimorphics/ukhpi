# Unit tests on the Region class

require 'test_helper'

class RegionTest < ActiveSupport::TestCase
  BOROUGH_TYPE = 'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough'.freeze
  COUNTY_TYPE = 'http://data.ordnancesurvey.co.uk/ontology/admingeo/County'.freeze

  let(:region) do
    Region.new('http://foo.bar/bam', { en: 'foo', cy: 'bar' },
               BOROUGH_TYPE,
               'http://foo.bar/parent', 'D12345678')
  end

  it 'should return the URI' do
    region.uri.must_equal 'http://foo.bar/bam'
  end

  it 'should return the type' do
    region.type.must_equal 'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough'
  end

  it 'should return the parent' do
    region.parent.must_equal 'http://foo.bar/parent'
  end

  it 'should return the GSS code' do
    region.gss.must_equal 'D12345678'
  end

  it 'should allow the label to be selected by language' do
    region.label(:en).must_equal 'foo'
    region.label(:cy).must_equal 'bar'
  end

  it 'should default to the English language label' do
    region.label.must_equal 'foo'
  end

  it 'should match the name and type' do
    region.matches_name?('foo', BOROUGH_TYPE, :en).must_be_truthy
    region.matches_name?('bar', BOROUGH_TYPE, :en).must_not_be_truthy
  end

  it 'should fail to match the name and different lang' do
    region.matches_name?('foo', COUNTY_TYPE, :en).must_not_be_truthy
    region.matches_name?('bar', COUNTY_TYPE, :en).must_not_be_truthy
  end

  it 'should match a partial name and type' do
    region.matches_name?('fo', BOROUGH_TYPE, :en).must_be_truthy
    region.matches_name?('ba', BOROUGH_TYPE, :en).must_not_be_truthy
  end

  it 'should allow the region type to be omitted' do
    region.matches_name?('foo', nil, :en).must_be_truthy
    region.matches_name?('bar', nil, :en).must_not_be_truthy
  end

  it 'should ignore case when matching' do
    region.matches_name?('FOO', nil, :en).must_be_truthy
    region.matches_name?('BaR', nil, :en).must_not_be_truthy
  end

  it 'should sort by label' do
    regions = [
      Region.new('http://foo.bar/a', { en: 'A' }, nil, nil, nil),
      Region.new('http://foo.bar/c', { en: 'C' }, nil, nil, nil),
      Region.new('http://foo.bar/b', { en: 'B' }, nil, nil, nil)
    ]
    regions.sort!
    regions[0].label.must_equal 'A'
    regions[1].label.must_equal 'B'
    regions[2].label.must_equal 'C'
  end
end
