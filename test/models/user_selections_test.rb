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
        _(selections.params.key?('location')).must_equal true
      end

      it 'should initialize the parameters correctly when given safe params' do
        selections = UserSelections.new(__safe_params: { 'location' => 'safe-test-region' })
        _(selections.params.key?('location')).must_equal true
      end
    end

    describe '#indicators' do
      it 'should access the selected indicator from the params' do
        selections = user_selections('in' => ['test-in'])
        _(selections.selected_indicators).must_equal(['test-in'])
        _(selections.selected_indicators(all: true)).must_equal(['test-in'])
      end

      it 'should recognise a legacy parameter' do
        selections = user_selections('ai' => ['test-in'])
        _(selections.selected_indicators).must_equal(['test-in'])
      end

      it 'should return the default value if nothing is defined' do
        _(user_selections({}).selected_indicators.length).must_be :>=, 2
        _(user_selections({}).selected_indicators).must_include 'hpi'
      end

      it 'should return all indicators if the all flag is true and no indicators are selected' do
        _(user_selections({}).selected_indicators(all: true).length).must_be :>=, 5
        _(user_selections({}).selected_indicators(all: true)).must_include 'hpi'
      end
    end

    describe '#selected_location' do
      it 'should retrieve the value given in the parameters' do
        _(user_selections('location' => 'foo').selected_location).must_equal 'foo'
      end

      it 'should retrieve the default value' do
        _(user_selections({}).selected_location).must_equal 'http://landregistry.data.gov.uk/id/region/united-kingdom'
      end
    end

    describe '#selected_statistics' do
      it 'should return the selected statistics if they are specified' do
        _(user_selections(st: ['fla']).selected_statistics).must_equal ['fla']
        _(user_selections(st: ['fla']).selected_statistics(all: true)).must_equal ['fla']
      end

      it 'should return the default statistics if they are not specified' do
        _(user_selections({}).selected_statistics).must_equal ['all']
      end

      it 'should allow returning all statistics if none are specified' do
        statistics = user_selections({}).selected_statistics(all: true)
        _(statistics.length).must_be :>=, 10
        _(statistics).must_include 'all'
      end
    end

    describe '#from_date' do
      it 'should convert a date string to a date' do
        _(user_selections('from' => '2017-09-18').from_date.month).must_equal 9
      end
    end

    describe '#with' do
      it 'should create a new user preferences with the new singular value' do
        selections0 = user_selections('location' => 'test-region-0')
        _(selections0.selected_location).must_equal 'test-region-0'
        from = selections0.from_date

        selections1 = selections0.with('from', '2017-03-25')
        _(selections0.selected_location).must_equal 'test-region-0'
        _(selections0.from_date).must_equal from
        _(selections1.from_date).must_equal Date.new(2017, 3, 25)

        selections2 = selections1.with('location', 'test-region-2')
        _(selections0.selected_location).must_equal 'test-region-0'
        _(selections2.selected_location).must_equal 'test-region-2'
        _(selections2.from_date).must_equal Date.new(2017, 3, 25)
      end

      it 'should create a new user preferences with an additional array value' do
        selections0 = user_selections('in' => ['averagePrice'])
        _(selections0.selected_indicators).must_equal ['averagePrice']

        selections1 = selections0.with('in', 'percentageMonthlyChange')
        _(selections0.selected_indicators).must_equal ['averagePrice']
        _(selections1.selected_indicators.length).must_equal 2
        _(selections1.selected_indicators).must_include 'averagePrice'
        _(selections1.selected_indicators).must_include 'percentageMonthlyChange'

        selections2 = selections1.with('in', 'percentageAnnualChange')
        _(selections0.selected_indicators).must_equal ['averagePrice']
        _(selections1.selected_indicators.length).must_equal 2
        _(selections2.selected_indicators.length).must_equal 3
        _(selections2.selected_indicators).must_include 'averagePrice'
        _(selections2.selected_indicators).must_include 'percentageMonthlyChange'
        _(selections2.selected_indicators).must_include 'percentageAnnualChange'
      end

      it 'should not create duplicate values in array-valued params' do
        selections0 = user_selections('in' => ['averagePrice'])
        selections1 = selections0.with('in', 'averagePrice')
        _(selections0.selected_indicators).must_equal ['averagePrice']
        _(selections1.selected_indicators).must_equal ['averagePrice']
      end
    end

    describe '#without' do
      it 'should create a new user preferences value without the given key for singlular values' do
        selections0 = user_selections('location' => 'test-region-0')
        _(selections0.selected_location).must_equal 'test-region-0'

        selections1 = selections0.without('location', 'does not matter')
        _(selections0.selected_location).must_equal 'test-region-0'
        assert selections0.params.key?('location')
        assert_not selections1.params.key?('location')
      end

      it 'should create a new user preferences value without the given value for array values' do
        selections0 = user_selections('in' => %w[averagePrice percentageMonthlyChange])
        _(selections0.selected_indicators.length).must_equal 2
        _(selections0.selected_indicators).must_include 'averagePrice'
        _(selections0.selected_indicators).must_include 'percentageMonthlyChange'

        selections1 = selections0.without('in', 'averagePrice')
        _(selections0.selected_indicators.length).must_equal 2
        _(selections1.selected_indicators.length).must_equal 1
        _(selections0.selected_indicators).must_include 'averagePrice'
        _(selections0.selected_indicators).must_include 'percentageMonthlyChange'
        _(selections1.selected_indicators).wont_include 'averagePrice'
        _(selections1.selected_indicators).must_include 'percentageMonthlyChange'
      end
    end

    describe '#summary' do
      it 'should produce a summary of the preferences including the theme' do
        selections = user_selections('thm' => ['property_type'],
                                     'from' => '2017-01',
                                     'to' => '2017-10',
                                     'location' => 'http://landregistry.data.gov.uk/id/region/england')
        _(selections.summary).must_equal 'property_type England from 2017-01 to 2017-10'
      end
    end

    describe '#valid?' do
      it 'should report the empty model is valid' do
        selections = user_selections({})
        _(selections.valid?).must_equal(true)
      end

      it 'should report that a correctly formatted from date is valid' do
        selections = user_selections(
          'from' => '2017-01-01'
        )
        _(selections.valid?).must_equal(true)
      end

      it 'should report that an incorrectly formatted from date is invalid' do
        selections = user_selections(
          'from' => '2017-0'
        )
        _(selections.valid?).must_equal(false)
        _(selections.errors).must_include('incorrect or missing "from" date')
      end

      it 'should allow a YYYY-MM date as valid' do
        selections = user_selections(
          'from' => '2017-01'
        )
        _(selections.valid?).must_equal(true)
        _(selections.errors).must_be_empty
      end

      it 'should report that an incorrectly formatted to date is invalid' do
        selections = user_selections(
          'to' => '2017-0'
        )
        _(selections.valid?).must_equal(false)
        _(selections.errors).must_include('incorrect or missing "to" date')
      end

      it 'should report that a correct location URI is valid' do
        selections = user_selections(
          location: 'http://landregistry.data.gov.uk/id/region/united-kingdom'
        )
        _(selections.valid?).must_equal(true)
      end

      it 'should report that an incorrect location URI is invalid' do
        selections = user_selections(
          location: 'http://landregistry.data.gov.uk/id/region/'
        )
        _(selections.valid?).must_equal(false)
        _(selections.errors).must_include('unrecognised location')
      end

      it 'should report that a correctly stated indicator is valid' do
        selections = user_selections('in' => %w[pac pmc])
        _(selections.valid?).must_equal(true)
      end

      it 'should report that an incorrectly stated indicator is not valid' do
        selections = user_selections('in' => %w[pmc percentageMonthlyWombles])
        _(selections.valid?).must_equal(false)
      end

      it 'should report that a correctly stated statistic is valid' do
        selections = user_selections('st' => %w[det sem])
        _(selections.valid?).must_equal(true)
      end

      it 'should report that an incorrectly stated statistic is not valid' do
        selections = user_selections('st' => %w[det percentageMonthlyWombles])
        _(selections.valid?).must_equal(false)
      end
    end

    describe 'language handling' do
      it 'should return English as the default' do
        selections = user_selections({})
        assert selections.english?
        assert_not selections.welsh?
      end

      it 'should return Welsh when that language is selected' do
        selections = user_selections('lang' => 'cy')
        current_locale = I18n.locale
        I18n.locale = :cy # simulate controller action

        assert_not selections.english?
        assert selections.welsh?
      ensure
        I18n.locale = current_locale
      end

      it 'should return English when that language is selected' do
        selections = user_selections('lang' => 'en')
        assert selections.english?
        assert_not selections.welsh?
      end

      it 'should ignore other languages' do
        selections = user_selections('lang' => 'fr')
        assert selections.english?
        assert_not selections.welsh?
      end

      it 'should generate the correct options to switch to Welsh language' do
        selections = user_selections(
          'from' => '2017-01'
        )

        alt_params = selections.alternative_language_params
        _(alt_params.params['from']).must_equal('2017-01')
        _(alt_params.params['lang']).must_equal('cy')
      end

      it 'should generate the correct options to switch to English language' do
        selections = user_selections(
          'from' => '2017-01',
          'lang' => 'cy'
        )
        current_locale = I18n.locale
        I18n.locale = :cy # this is what the controller would do

        alt_params = selections.alternative_language_params
        _(alt_params.params['from']).must_equal('2017-01')
        _(alt_params.params['lang']).must_equal('en')
      ensure
        I18n.locale = current_locale
      end
    end
  end
end
