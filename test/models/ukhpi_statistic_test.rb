# frozen-string-literal: true

require 'test_helper'

# Unit tests on the UkhpiStatistic class
class UkhpiStatisticTest < ActiveSupport::TestCase
  describe 'UkhpiStatistic' do
    describe '#initialize' do
      it 'should provide accessors to initialization state' do
        stat = UkhpiStatistic.new('foo', 'foo_r', 'all_property_types', true)
        stat.slug.must_equal 'foo'
        stat.root_name.must_equal 'foo_r'
        stat.label.must_equal 'All property types'
      end
    end

    describe '#volume?' do
      it 'should correctly return whether or not a statistic admits a volumne indicator' do
        assert UkhpiStatistic.new('foo', 'foo_r', 'all_property_types', true).volume?
        assert_not UkhpiStatistic.new('foo', 'foo_r', 'all_property_types', false).volume?
      end
    end

    describe '#selected?' do
      it 'should correctly determine whether a statistic is selected' do
        user_selections = stub(selected_statistics: ['foo'])
        assert UkhpiStatistic.new('foo', 'foo_r', 'a', true).selected?(user_selections)
        assert_not UkhpiStatistic.new('bar', 'bar_r', 'b', false).selected?(user_selections)
      end
    end

    describe '#to_h' do
      it 'should serialize the statistic to a hash correctly when selected' do
        user_selections = stub(selected_statistics: ['foo'])
        hash = UkhpiStatistic
               .new('foo', 'foo_r', 'all_property_types', true)
               .to_h(user_selections)

        hash[:slug].must_equal 'foo'
        hash[:rootName].must_equal 'foo_r'
        hash[:label].must_equal 'All property types'
        hash[:hasVolume].must_equal true
        hash[:isSelected].must_equal true
      end

      it 'should serialize the statistic to a hash correctly when not selected' do
        user_selections = stub(selected_statistics: ['foo'])
        hash = UkhpiStatistic
               .new('bar', 'foo_r', 'all_property_types', true)
               .to_h(user_selections)

        hash[:isSelected].must_equal false
      end
    end
  end
end
