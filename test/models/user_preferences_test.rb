# Unit tests on the UserPreferences class

require 'test_helper'

class UserPreferencesTest < ActiveSupport::TestCase

  it "permits access to whitelisted parameters" do
    up = UserPreferences.new( {"region" => "foo"})
    up.region.must_equal "foo"
    up.from.must_be_nil
    up.to.must_be_nil
  end

  it "returns nil for non-whitelist parameters" do
    up = UserPreferences.new( {"region" => "foo"})
    up.womble.must_not_be_truthy
  end

  it "provides a default value for region" do
    up = UserPreferences.new( {"region" => ""})
    up.region.wont_be_nil
    up.region.start_with?( "http:" )
  end

  it "accepts valid dates" do
    up = UserPreferences.new( {"from" => "2015-01-01", "to" => "2016-01-01" })
    up.from.must_be_kind_of Date
    up.to.must_be_kind_of Date
  end

  it "rejects invalid dates" do
    lambda {
      UserPreferences.new( {"from" => "century of the fruitbat"} )
    }.must_raise ArgumentError
  end

  it "allows a null date" do
    up = UserPreferences.new( {"region" => "foo", "from" => "", "to" => ""})
    up.from.must_be_nil
    up.to.must_be_nil
  end

  it "allows a parameter to be set" do
    up = UserPreferences.new( {"region" => "foo"})
    up0 = up.with( :region, "bar" )
    up.region.must_equal "foo"
    up0.region.must_equal "bar"
  end

  it "ignores an empty selection for aspects" do
    up = UserPreferences.new( "aspects" => "" )
    up.aspects.must_be_nil
  end

  it "reports selected aspects as an array" do
    up = UserPreferences.new( "aspects" => ["foo", "bar"] )
    up.aspects.must_be_kind_of Array
    up.aspects.first.must_equal :foo
    up.aspects.second.must_equal :bar
    up.aspects.length.must_equal 2
  end

  it "decodes selected aspects as an array" do
    up = UserPreferences.new( "aspects" => "foo,bar" )
    up.aspects.must_be_kind_of Array
    up.aspects.first.must_equal :foo
    up.aspects.second.must_equal :bar
    up.aspects.length.must_equal 2
  end

  it "wraps a single aspect as an array" do
    up = UserPreferences.new( "aspects" => "foo" )
    up.aspects.must_be_kind_of Array
    up.aspects.first.must_equal :foo
    up.aspects.length.must_equal 1
  end

  it "can encode parameters as a URL search string" do
    UserPreferences
      .new( "region" => "foo", "from" => "2016-04-04" )
      .as_search_string
      .must_equal "from=2016-04-04&region=foo"
  end

  it "can encode array-valued parameters as a search string" do
    UserPreferences
      .new( "aspects" => ["foo", "bar"] )
      .as_search_string
      .must_equal "aspects=foo,bar"
  end

  it "should return itself when asked for preferences" do
    up = UserPreferences.new( {} )
    up.prefs.must_be_same_as up
  end

  it "should summarise itself" do
    up = UserPreferences.new( "region" => "foo" )
    up.summary.must_equal( "Search term: foo" )

    up1 = UserPreferences.new( "region" => "foo", "to" => "2016-01-01" )
    up1.summary.must_equal( "Search term: foo, to 2016-01-01" )
  end
end

