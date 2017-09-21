# frozen_string_literal: true

require 'test_helper'

# Unit tests on the Location class
class RegionTest < ActiveSupport::TestCase
  BOROUGH_TYPE = 'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough'
  COUNTY_TYPE = 'http://data.ordnancesurvey.co.uk/ontology/admingeo/County'

  let(:region) do
    Location.new('http://foo.bar/bam', { en: 'foo', cy: 'bar' },
                 BOROUGH_TYPE,
                 'http://foo.bar/parent',
                 'D12345678')
  end

  describe 'Location' do
    describe '#uri' do
      it 'should return the URI' do
        region.uri.must_equal 'http://foo.bar/bam'
      end
    end

    describe '#type' do
      it 'should return the type' do
        region.type.must_equal 'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough'
      end
    end

    describe '#parent' do
      it 'should return the parent' do
        region.parent.must_equal 'http://foo.bar/parent'
      end
    end

    describe '#gss' do
      it 'should return the GSS code' do
        region.gss.must_equal 'D12345678'
      end
    end

    describe '#label' do
      it 'should allow the label to be selected by language' do
        region.label(:en).must_equal 'foo'
        region.label(:cy).must_equal 'bar'
      end

      it 'should default to the English language label' do
        region.label.must_equal 'foo'
      end
    end

    describe '#matches_name?' do
      it 'should match the name and type' do
        assert region.matches_name?('foo', [BOROUGH_TYPE], :en)
        refute region.matches_name?('bar', [BOROUGH_TYPE], :en)

        refute region.matches_name?('foo', [COUNTY_TYPE], :en)
        assert region.matches_name?('foo', [COUNTY_TYPE, BOROUGH_TYPE], :en)
      end

      it 'should fail to match the name and different lang' do
        refute region.matches_name?('foo', [COUNTY_TYPE], :en)
        refute region.matches_name?('bar', [COUNTY_TYPE], :en)
      end

      it 'should match a partial name and type' do
        assert region.matches_name?('fo', [BOROUGH_TYPE], :en)
        refute region.matches_name?('ba', [BOROUGH_TYPE], :en)
      end

      it 'should allow the region type to be omitted' do
        assert region.matches_name?('foo', [], :en)
        refute region.matches_name?('bar', [], :en)
      end

      it 'should ignore case when matching' do
        assert region.matches_name?('FOO', [], :en)
        refute region.matches_name?('BaR', [], :en)
      end
    end

    describe 'sorting' do
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
  end
end
