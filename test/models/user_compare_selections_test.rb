# frozen_string_literal: true

require 'test_helper'

# Unit tests on UserCompareSelections class
class UserCompareSelectionsTest < ActiveSupport::TestCase
  describe 'UserCompareSelections' do
    describe '#initialize' do
      it 'should allow permitted params' do
        params = ActionController::Parameters.new(from: '2019-12-01')
        fixture = UserCompareSelections
                  .new(params)
                  .from_date
        _(fixture).must_equal(DateTime.new(2019, 12, 1))
      end

      it 'should reject unpermitted params' do
        params = ActionController::Parameters.new(frome: '2019-12-01')
        fixture = UserCompareSelections.new(params)
        _(fixture.to_h.keys).wont_include('frome')
      end

      it 'should pass through pre-checked params' do
        params = ActionController::Parameters.new(__safe_params: { from: '2019-12-02' })
        fixture = UserCompareSelections.new(params)
        _(fixture.from_date).must_equal(DateTime.new(2019, 12, 2))
      end
    end

    describe '#user_params_model' do
      it 'should return the params model' do
        params = ActionController::Parameters.new({})
        fixture = UserCompareSelections.new(params).user_params_model
        _(fixture.keys).must_include('from')
      end
    end

    describe '#selected_locations' do
      it 'should return the selected locations' do
        params = ActionController::Parameters.new(
          'location' => ['S92000003']
        )
        fixture = UserCompareSelections.new(params).selected_locations
        _(fixture.first.label).must_equal('Scotland')
      end

      it 'should raise an error if the location is undefined' do
        params = ActionController::Parameters.new(
          'location' => ['wimbledon common']
        )
        fixture = UserCompareSelections.new(params)

        _(lambda {
          fixture.selected_locations
        }).must_raise(ActionController::BadRequest)
      end
    end

    describe '#from_date' do
      it 'should return the from date' do
        params = ActionController::Parameters.new(from: '2019-12-01')
        fixture = UserCompareSelections
                  .new(params)
                  .from_date
        _(fixture).must_equal(DateTime.new(2019, 12, 1))
      end
    end

    describe '#to_date' do
      it 'should return the to date' do
        params = ActionController::Parameters.new(to: '2019-12-02')
        fixture = UserCompareSelections
                  .new(params)
                  .to_date
        _(fixture).must_equal(DateTime.new(2019, 12, 2))
      end
    end

    describe '#selected_statistic' do
      it 'should return the selected statistic' do
        params = ActionController::Parameters.new(st: 'avg')
        fixture = UserCompareSelections
                  .new(params)
                  .selected_statistic
        _(fixture).must_equal('avg')
      end

      it 'should return an array of the selected statistics' do
        params = ActionController::Parameters.new(st: 'avg')
        fixture = UserCompareSelections
                  .new(params)
                  .selected_statistics
        _(fixture).must_equal(['avg'])
      end

      it 'should return the default statistic' do
        params = ActionController::Parameters.new({})
        fixture = UserCompareSelections
                  .new(params)
                  .selected_statistics
        _(fixture).must_equal(['all'])
      end
    end

    describe '#selected_indicator' do
      it 'should return the selected indicator' do
        params = ActionController::Parameters.new(in: 'hpi')
        fixture = UserCompareSelections
                  .new(params)
                  .selected_indicator
        _(fixture).must_equal('hpi')
      end

      it 'should return an array of the selected indicators' do
        params = ActionController::Parameters.new(in: 'hpi')
        fixture = UserCompareSelections
                  .new(params)
                  .selected_indicators
        _(fixture).must_equal(['hpi'])
      end

      it 'should return the default indicator' do
        params = ActionController::Parameters.new({})
        fixture = UserCompareSelections
                  .new(params)
                  .selected_indicators
        _(fixture).must_equal(['hpi'])
      end
    end

    describe 'search' do
      it 'should return the search term' do
        params = ActionController::Parameters.new('location-term': 'womble')
        fixture = UserCompareSelections
                  .new(params)
                  .search_term
        _(fixture).must_equal('womble')
      end

      it 'should return true for a search' do
        params = ActionController::Parameters.new(
          'location-term': 'womble',
          'form-action': 'search'
        )

        fixture = UserCompareSelections
                  .new(params)
                  .search?
        _(fixture).must_equal(true)
      end

      it 'should return false for a non-search' do
        params = ActionController::Parameters.new(
          'location-term': 'womble',
          'form-action': 'stop, drop, roll'
        )

        fixture = UserCompareSelections
                  .new(params)
                  .search?
        _(fixture).must_equal(false)
      end
    end

    describe '#as_json' do
      it 'should return a JSON description' do
        params = ActionController::Parameters.new(
          from: '2018-12-01',
          to: '2019-12-01'
        )
        fixture = UserCompareSelections
                  .new(params)
                  .as_json

        _(fixture[:from]).must_equal('{"date":"2018-12-01"}')
        _(fixture[:to]).must_equal('{"date":"2019-12-01"}')
        _(fixture.keys.length).must_equal(7)
      end
    end
  end
end
