# frozen_string_literal: true

require 'test_helper'

# Unit tests on the UkhpiIndicator class
class UkhpiIndicatorTest < ActiveSupport::TestCase
  describe 'UkhpiIndicator' do
    describe '#initialize' do
      it 'should provide access to the initialised values' do
        ind = UkhpiIndicator.new('foo', 'foo_root', 'average_price')
        ind.slug.must_equal 'foo'
        ind.root_name.must_equal 'foo_root'
        ind.label.must_equal 'Average price'
      end
    end

    describe '#volume?' do
      it 'should return correctly whether or not this is a volume indicator' do
        refute UkhpiIndicator.new('foo', 'foo_r', 'foo_l').volume?
        assert UkhpiIndicator.new('vol', 'foo_r', 'foo_l').volume?
      end
    end

    describe '#to_h' do
      it 'should correctly convert the indicator to a hash' do
        user_selections = stub(selected_indicators: ['foo'])

        hash = UkhpiIndicator.new('foo', 'r', 'average_price').to_h(user_selections)
        hash[:slug].must_equal 'foo'
        hash[:rootName].must_equal 'r'
        hash[:label].must_equal 'Average price'
        hash[:isVolume].must_equal false
        hash[:isSelected].must_equal true

        hash = UkhpiIndicator.new('bar', 'r', 'average_price').to_h(user_selections)
        hash[:isSelected].must_equal false
      end
    end
  end
end
