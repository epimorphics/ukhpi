# frozen-string-literal: true

require 'test_helper'

# Unit tests on the UkhpiTheme class
class UkhpiThemeTest < ActiveSupport::TestCase
  describe 'UkhpiTheme' do
    describe '#initialize' do
      it 'should provide accessors to initialization state' do
        stat = stub
        theme = UkhpiTheme.new('foo', [stat])
        theme.slug.must_equal 'foo'
        theme.statistics.length.must_equal 1
      end
    end

    describe '#indicators' do
      it 'should correctly return all indicators including volumne indicator' do
        stat0 = stub(volume?: true)
        stat1 = stub(volume?: false)

        UkhpiTheme.new('foo', [stat0]).indicators.length.must_equal 5
        UkhpiTheme.new('foo', [stat1]).indicators.length.must_equal 4
        UkhpiTheme.new('foo', [stat0, stat1]).indicators.length.must_equal 5
      end
    end

    describe '#label' do
      it 'should return the label correctly' do
        UkhpiTheme.new('property_type', []).label.must_equal 'Type of property'
      end
    end

    describe '#to_h' do
      it 'should serialize the statistic to a hash correctly when selected' do
        stat0 = stub(volume?: true, to_h: {})
        stat1 = stub(volume?: false, to_h: {})
        user_selections = stub

        hash = UkhpiTheme.new('property_type', [stat0, stat1]).to_h(user_selections)

        hash[:slug].must_equal 'property_type'
        hash[:label].must_equal 'Type of property'
        hash[:statistics].length.must_equal 2
      end
    end
  end
end
