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

  it "rejects invalid values for region" do
    lambda {
      UserPreferences.new( {"region" => ""})
    }.must_raise RuntimeError
  end

  it "accepts valid dates" do
    up = UserPreferences.new( {"from" => "2015-01-01", "to" => "2016-01-01" })
    up.from.must_be_kind_of Date
    up.to.must_be_kind_of Date
  end
end

