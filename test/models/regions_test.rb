# Unit tests on the Regions class

require 'test_helper'

class RegionsTest < ActiveSupport::TestCase

  it "recognise a valid region type" do
    region = "http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough"
    Regions.validate_region_type( region ).must_equal region
  end

  it "recognise a valid region type" do
    lambda {
      Regions.validate_region_type( "http://data.ordnancesurvey.co.uk/ontology/admingeo/Banana" )
    }.must_raise RuntimeError
  end

  it "allows region type to be empty" do
    Regions.validate_region_type( nil ).must_be_nil
  end

  it "matches a full region name with a type" do
    hits = Regions.match( "Mendip", {} )
    hits.must_be_kind_of Hash
    hits.size.must_equal 1

    r = hits.values.first
    r.must_be_kind_of Region
    r.label( :en ).must_equal "Mendip"
  end

  it "matches multiple values when given a partial name" do
    hits = Regions.match( "South", {} )
    hits.must_be_kind_of Hash
    hits.size.must_be :>, 20
  end

  it "matches fewer values when constrained by type" do
    hits = Regions.match( "South", {rt: "http://data.ordnancesurvey.co.uk/ontology/admingeo/District"} )
    hits.must_be_kind_of Hash
    hits.size.must_be :<, 20
  end

  it "returns empty for an unsatisfiable search" do
    hits = Regions.match( "Mendip", {rt: "http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough"} )
    hits.must_be_kind_of Hash
    hits.must_be_empty
  end

  it "allows a location to be looked up by URI" do
    loc = Regions.lookup_region( "http://landregistry.data.gov.uk/id/region/south-east" )
    loc.label( :en ).must_equal "South East"
  end

  it "returns nil if the lookup URI does not match anything" do
    Regions.lookup_region( "http" ).must_be_nil
  end
end
