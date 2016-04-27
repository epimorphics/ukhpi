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

  it "supports iteration by each()" do
    labels = []
    Aspects.new( nil ).each {|a| labels << a.label}
    labels.length.must_be :>, 30
    labels.must_include "Average price"
  end

  it "should group aspects into convenient groups" do
    ag = Aspects.new(nil).aspect_groups
    ag.first.label.must_equal "overall indices"
    ag.first.advanced?.must_equal false

    ag.second.label.must_equal "detached houses"
    ag.second.advanced?.must_equal false

    # each measure is a pair [label, measure]
    m = ag.first.measures.first
    m.first.must_equal "index"
    m.second.label.must_equal "Index"

    m = ag.second.measures.first
    m.first.must_equal "index"
    m.second.label.must_equal "Detached property index"
  end
end
