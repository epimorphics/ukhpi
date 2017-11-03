# frozen_string_literal: true

require 'test_helper'

def user_selections(params)
  UserSelections.new(ActionController::Parameters.new(params))
end

# Unit tests on the UserSelections class
class UserSelectionsTest < ActiveSupport::TestCase
  describe 'UserSelections' do
    describe '#initialize' do
      it 'should process the parameters correctly with action-controller params' do
        selections = user_selections('location' => 'test-region')
        selections.params.key?('location').must_equal true
      end

      it 'should initialize the parameters correctly when given safe params' do
        selections = UserSelections.new(__safe_params: { 'location' => 'safe-test-region' })
        selections.params.key?('location').must_equal true
      end
    end

    describe '#indicators' do
      it 'should access the selected indicator from the params' do
        selections = user_selections('in' => ['test-in'])
        selections.selected_indicators.must_equal(['test-in'])
      end

      it 'should recognise a legacy parameter' do
        selections = user_selections('ai' => ['test-in'])
        selections.selected_indicators.must_equal(['test-in'])
      end

      it 'should return the default value if nothing is defined' do
        user_selections({}).selected_indicators.length.must_be :>=, 2
        user_selections({}).selected_indicators.must_include 'hpi'
      end
    end

    describe '#selected_location' do
      it 'should retrieve the value given in the parameters' do
        user_selections('location' => 'foo').selected_location.must_equal 'foo'
      end

      it 'should retrieve the default value' do
        user_selections({}).selected_location.must_equal 'http://landregistry.data.gov.uk/id/region/united-kingdom'
      end
    end

    describe '#from_date' do
      it 'should convert a date string to a date' do
        user_selections('from' => '2017-09-18').from_date.month.must_equal 9
      end
    end

    describe '#with' do
      it 'should create a new user preferences with the new singular value' do
        selections0 = user_selections('location' => 'test-region-0')
        selections0.selected_location.must_equal 'test-region-0'
        from = selections0.from_date

        selections1 = selections0.with('from', '2017-03-25')
        selections0.selected_location.must_equal 'test-region-0'
        selections0.from_date.must_equal from
        selections1.from_date.must_equal Date.new(2017, 3, 25)

        selections2 = selections1.with('location', 'test-region-2')
        selections0.selected_location.must_equal 'test-region-0'
        selections2.selected_location.must_equal 'test-region-2'
        selections2.from_date.must_equal Date.new(2017, 3, 25)
      end

      it 'should create a new user preferences with an additional array value' do
        selections0 = user_selections('in' => ['averagePrice'])
        selections0.selected_indicators.must_equal ['averagePrice']

        selections1 = selections0.with('in', 'percentageMonthlyChange')
        selections0.selected_indicators.must_equal ['averagePrice']
        selections1.selected_indicators.length.must_equal 2
        selections1.selected_indicators.must_include 'averagePrice'
        selections1.selected_indicators.must_include 'percentageMonthlyChange'

        selections2 = selections1.with('in', 'percentageAnnualChange')
        selections0.selected_indicators.must_equal ['averagePrice']
        selections1.selected_indicators.length.must_equal 2
        selections2.selected_indicators.length.must_equal 3
        selections2.selected_indicators.must_include 'averagePrice'
        selections2.selected_indicators.must_include 'percentageMonthlyChange'
        selections2.selected_indicators.must_include 'percentageAnnualChange'
      end

      it 'should not create duplicate values in array-valued params' do
        selections0 = user_selections('in' => ['averagePrice'])
        selections1 = selections0.with('in', 'averagePrice')
        selections0.selected_indicators.must_equal ['averagePrice']
        selections1.selected_indicators.must_equal ['averagePrice']
      end
    end

    describe '#without' do
      it 'should create a new user preferences value without the given key for singlular values' do
        selections0 = user_selections('location' => 'test-region-0')
        selections0.selected_location.must_equal 'test-region-0'

        selections1 = selections0.without('location', 'does not matter')
        selections0.selected_location.must_equal 'test-region-0'
        assert selections0.params.key?('location')
        refute selections1.params.key?('location')
      end

      it 'should create a new user preferences value without the given value for array values' do
        selections0 = user_selections('in' => %w[averagePrice percentageMonthlyChange])
        selections0.selected_indicators.length.must_equal 2
        selections0.selected_indicators.must_include 'averagePrice'
        selections0.selected_indicators.must_include 'percentageMonthlyChange'

        selections1 = selections0.without('in', 'averagePrice')
        selections0.selected_indicators.length.must_equal 2
        selections1.selected_indicators.length.must_equal 1
        selections0.selected_indicators.must_include 'averagePrice'
        selections0.selected_indicators.must_include 'percentageMonthlyChange'
        selections1.selected_indicators.wont_include 'averagePrice'
        selections1.selected_indicators.must_include 'percentageMonthlyChange'
      end
    end

    describe '#summary' do
      it 'should produce a summary of the preferences including the theme' do
        selections = user_selections('thm' => ['property_type'],
                                     'from' => '2017-01',
                                     'to' => '2017-10',
                                     'location' => 'http://landregistry.data.gov.uk/id/region/england')
        selections.summary.must_equal 'property_type England from 2017-01 to 2017-10'
      end
    end
  end
end
