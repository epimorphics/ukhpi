# Unit tests on the Aspects class

require 'test_helper'

class AspectsTest < ActiveSupport::TestCase
  it "should define some default aspects" do
    up = UserPreferences.new( {} )
    asp = Aspects.new( up )
    asp.visible_aspects.wont_be_nil
    asp.visible_aspects.length.must_be :>=, 4
  end

  it "respects the users preferred aspects" do
    up = UserPreferences.new( {"aspects" => ["foo", "bar"]} )
    asp = Aspects.new( up )
    asp.visible_aspects.length.must_equal 2
    asp.visible_aspects.first.must_equal :foo
    asp.visible_aspects.second.must_equal :bar
  end

  it "allows aspects to be looked up by slug" do
    Aspects.new( nil ).aspect( :ap ).label.must_equal "Average price"
  end
end
