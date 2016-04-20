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
    labels.must_include "Average price"
  end

  it "should retrieve the comments for each component" do
    dsd = DataModel.new
    comments = dsd.measures.map &:comment
    comments.must_include "The percentage change in the average house price compared to the same period twelve months earlier."
  end

  it "should separate out the dimensions" do
    dsd = DataModel.new
    dsd.dimensions.count.must_equal 2
  end

  it "should separate out the measures" do
    dsd = DataModel.new
    dsd.measures.count.must_equal 47
  end

  it "should produce a unique slug for each measure" do
    dsd = DataModel.new
    slugs = dsd.measures.map &:slug
    slugs.must_include "apsd"
    slugs.uniq.length.must_equal slugs.length
  end

  it "should produce a qname for each measure" do
    dsd = DataModel.new
    slugs = dsd.measures.map &:qname
    slugs.must_include "ukhpi:averagePriceSemiDetached"
    slugs.uniq.length.must_equal slugs.length
  end
end
