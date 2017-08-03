# Unit tests on the Aspects class

require 'test_helper'

class AspectsTest < ActiveSupport::TestCase
  it 'should define some default aspects' do
    up = UserPreferences.new({})
    asp = Aspects.new(up)
    asp.visible_aspects.wont_be_nil
    asp.visible_aspects.length.must_be :>=, 4
  end

  it 'respects the users preferred aspects' do
    up = UserPreferences.new('ac' => ['SemiDetached'], 'ai' => %w[housePriceIndex averagePrice])
    asp = Aspects.new(up)
    asp.visible_aspects.length.must_equal 2
    asp.visible_aspects.first.must_equal :housePriceIndexSemiDetached
    asp.visible_aspects.second.must_equal :averagePriceSemiDetached
  end

  it 'supports iteration by each()' do
    labels = []
    Aspects.new(nil).each { |a| labels << a.label }
    labels.length.must_be :>, 30
    labels.must_include 'Average price'
  end
end
