# frozen_string_literal: true

# Unit tests on the Locations class

require 'test_helper'

class LocationsTest < ActiveSupport::TestCase
  it 'recognise a valid region type' do
    region = 'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough'
    _(Locations.validate_location_type(region)).must_equal region
  end

  it 'recognise a valid region type' do
    _(lambda {
      Locations.validate_location_type('http://data.ordnancesurvey.co.uk/ontology/admingeo/Banana')
    }).must_raise ArgumentError
  end

  it 'allows region type to be empty' do
    _(Locations.validate_location_type(nil)).must_be_nil
  end

  it 'matches a full region name with a type' do
    hits = Locations.match('Mendip', {})
    _(hits).must_be_kind_of Hash
    _(hits.size).must_equal 1

    r = hits.values.first
    _(r).must_be_kind_of Location
    _(r.label(:en)).must_equal 'Mendip'
  end

  it 'matches multiple values when given a partial name' do
    hits = Locations.match('South', {})
    _(hits).must_be_kind_of Hash
    _(hits.size).must_be :>, 20
  end

  it 'matches fewer values when constrained by type' do
    hits = Locations.match('South', rt: 'http://data.ordnancesurvey.co.uk/ontology/admingeo/District')
    _(hits).must_be_kind_of Hash
    _(hits.size).must_be :<, 20
  end

  it 'returns empty for an unsatisfiable search' do
    hits = Locations.match('Mendip', rt: 'http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough')
    _(hits).must_be_kind_of Hash
    _(hits).must_be_empty
  end

  it 'allows a location to be looked up by URI' do
    loc = Locations.lookup_location('http://landregistry.data.gov.uk/id/region/south-east')
    _(loc.label(:en)).must_equal 'South East'
  end

  it 'returns nil if the lookup URI does not match anything' do
    _(Locations.lookup_location('http')).must_be_nil
  end

  it 'ensures that we have a Welsh name for all Welsh LAs' do
    loc = Locations.lookup_location('http://landregistry.data.gov.uk/id/region/gwynedd')
    _(loc.label(:en)).must_equal 'Gwynedd'
    _(loc.label(:cy)).must_equal 'Gwynedd'
  end
end
