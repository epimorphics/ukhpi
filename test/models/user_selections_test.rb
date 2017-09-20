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
        selections.indicators.must_equal(['test-in'])
      end

      it 'should recognise a legacy parameter' do
        selections = user_selections('ai' => ['test-in'])
        selections.indicators.must_equal(['test-in'])
      end

      it 'should return the default value if nothing is defined' do
        user_selections({}).indicators.length.must_be :>=, 4
        user_selections({}).indicators.must_include 'averagePrice'
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

    describe '#with' do
      it 'should create a new user preferences with an additional value' do
        selections0 = user_selections('location' => 'test-region-0')
        selections0.selected_location.must_equal 'test-region-0'

        selections1 = selections0.with('in', ['averagePrice'])
        selections0.selected_location.must_equal 'test-region-0'
        selections0.indicators.length.must_be :>=, 4
        selections1.selected_location.must_equal 'test-region-0'
        selections1.indicators.must_equal ['averagePrice']

        selections2 = selections1.with('location', 'test-region-2')
        selections0.selected_location.must_equal 'test-region-0'
        selections0.indicators.length.must_be :>=, 4
        selections2.selected_location.must_equal 'test-region-2'
        selections2.indicators.must_equal ['averagePrice']
      end
    end
  end
end
