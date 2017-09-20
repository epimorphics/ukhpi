# frozen_string_literal: true

require 'test_helper'

def user_selections(params)
  UserSelections.new(ActionController::Parameters.new(params))
end

# Unit tests on the UserSelections class
class UserSelectionsTest < ActiveSupport::TestCase
  describe 'UserSelections' do
    describe '#initialize' do
      it 'should process the parameters correctly' do
        selections = user_selections('region' => 'test-region')
        selections.params.key?('region')
      end
    end

    describe '#indicators' do
      it 'should access the selected region from the params' do
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
  end
end
