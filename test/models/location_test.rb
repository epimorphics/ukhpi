# frozen_string_literal: true

require 'test_helper'
require 'location'

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
        _(region.uri).must_equal 'http://foo.bar/bam'
      end
    end

    describe '#type' do
      it 'should return the type' do
        _(region.type).must_equal 'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough'
      end
    end

    describe '#parent' do
      it 'should return the parent' do
        _(region.parent).must_equal 'http://foo.bar/parent'
      end
    end

    describe '#gss' do
      it 'should return the GSS code' do
        _(region.gss).must_equal 'D12345678'
      end
    end

    describe '#label' do
      it 'should allow the label to be selected by language' do
        _(region.label(:en)).must_equal 'foo'
        _(region.label(:cy)).must_equal 'bar'
      end

      it 'should default to the English language label' do
        _(region.label).must_equal 'foo'
      end
    end

    describe '#matches_name?' do
      it 'should match the name and type' do
        assert region.matches_name?('foo', [BOROUGH_TYPE], :en)
        assert_not region.matches_name?('bar', [BOROUGH_TYPE], :en)

        assert_not region.matches_name?('foo', [COUNTY_TYPE], :en)
        assert region.matches_name?('foo', [COUNTY_TYPE, BOROUGH_TYPE], :en)
      end

      it 'should fail to match the name and different lang' do
        assert_not region.matches_name?('foo', [COUNTY_TYPE], :en)
        assert_not region.matches_name?('bar', [COUNTY_TYPE], :en)
      end

      it 'should match a partial name and type' do
        assert region.matches_name?('fo', [BOROUGH_TYPE], :en)
        assert_not region.matches_name?('ba', [BOROUGH_TYPE], :en)
      end

      it 'should allow the region type to be omitted' do
        assert region.matches_name?('foo', [], :en)
        assert_not region.matches_name?('bar', [], :en)
      end

      it 'should ignore case when matching' do
        assert region.matches_name?('FOO', [], :en)
        assert_not region.matches_name?('BaR', [], :en)
      end
    end

    describe 'sorting' do
      it 'should sort by label' do
        regions = [
          Location.new('http://foo.bar/a', { en: 'A' }, nil, nil, nil),
          Location.new('http://foo.bar/c', { en: 'C' }, nil, nil, nil),
          Location.new('http://foo.bar/b', { en: 'B' }, nil, nil, nil)
        ]
        regions.sort!
        _(regions[0].label).must_equal 'A'
        _(regions[1].label).must_equal 'B'
        _(regions[2].label).must_equal 'C'
      end
    end

    describe 'Welsh language support' do
      it 'should return true if a location is in Wales' do
        fixture = Location.new('http://example.com/a', { en: 'A' }, nil, nil, nil)
        fixture_w = Location.new('http://example.com/a', { en: 'A' }, nil, Location::WALES, nil)

        assert_not fixture.in_wales?
        assert fixture_w.in_wales?
      end

      it 'should return true if a location has a Welsh label' do
        fixture = Location.new('http://example.com/a', { en: 'A' }, nil, nil, nil)
        fixture_w = Location.new('http://example.com/y', { en: 'A', cy: 'Y' }, nil, nil, nil)

        assert_not fixture.welsh_name?
        assert fixture_w.welsh_name?
      end

      it 'should return false if the Welsh and English names are identical' do
        fixture_w = Location.new('http://example.com/y', { en: 'Abcd', cy: 'Abcd' }, nil, nil, nil)

        assert_not fixture_w.welsh_name?
      end

      it 'should return Boolean based on whether a location is in Wales' do
        fixture0 = Location.new('http://example.com/1', {}, nil, 'http://atlantis.com', nil)
        fixture1 = Location.new('http://example.com/1', {}, nil, Location::WALES, nil)
        fixture2 = Location.new(Location::WALES, {}, nil, nil, nil)

        assert_not fixture0.in_wales?
        assert fixture1.in_wales?
        assert fixture2.in_wales?
      end
    end
  end
end
