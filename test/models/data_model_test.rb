# Unit tests on the DataModel class and helpers

require 'test_helper'

class SearchCommandTest < ActiveSupport::TestCase
  it "should load the DSD" do
    dsd = DataModel.new
    dsd.model.wont_be_nil
  end

  it "should list the components" do
    dsd = DataModel.new
    dsd.components.count.must_equal 49
  end

  it "should retrieve the labels for each compoonent" do
    dsd = DataModel.new
    labels = dsd.measures.map &:label
    labels.include?( "Average price" ).must_equal true
  end

  it "should retrieve the comments for each component" do
    dsd = DataModel.new
    comments = dsd.measures.map &:comment
    comments.include?( "The percentage change in the average house price compared to the previous month." ).must_equal true
  end

  it "should separate out the dimensions" do
    dsd = DataModel.new
    dsd.dimensions.count.must_equal 2
  end

  it "should separate out the measures" do
    dsd = DataModel.new
    dsd.measures.count.must_equal 47
  end
end
