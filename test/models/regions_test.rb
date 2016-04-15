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

end
