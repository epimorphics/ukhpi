# frozen_string_literal: true

require 'test_helper'

# Unit tests on the UkhpiIndicator class
class UkhpiIndicatorTest < ActiveSupport::TestCase
  describe 'UkhpiIndicator' do
    describe '#initialize' do
      it 'should provide access to the initialised values' do
        ind = UkhpiIndicator.new('foo', 'foo_root', 'average_price')
        _(ind.slug).must_equal 'foo'
        _(ind.root_name).must_equal 'foo_root'
        _(ind.label).must_equal 'Average price'
      end
    end

    describe '#volume?' do
      it 'should return correctly whether or not this is a volume indicator' do
        assert_not UkhpiIndicator.new('foo', 'foo_r', 'foo_l').volume?
        assert UkhpiIndicator.new('vol', 'foo_r', 'foo_l').volume?
      end
    end

    describe '#to_h' do
      it 'should correctly convert the indicator to a hash' do
        user_selections = stub(selected_indicators: ['foo'])

        hash = UkhpiIndicator.new('foo', 'r', 'average_price').to_h(user_selections)
        _(hash[:slug]).must_equal 'foo'
        _(hash[:rootName]).must_equal 'r'
        _(hash[:label]).must_equal 'Average price'
        _(hash[:isVolume]).must_equal false
        _(hash[:isSelected]).must_equal true

        hash = UkhpiIndicator.new('bar', 'r', 'average_price').to_h(user_selections)
        _(hash[:isSelected]).must_equal false
      end
    end
  end
end
