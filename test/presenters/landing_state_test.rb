# frozen_string_literal: true

# Unit tests on the LandingState class

require 'test_helper'

class LandingStateTest < ActiveSupport::TestCase
  def mock_latest_value_data
    {
      'ukhpi:refMonth' => { '@value' => '2016-01' },
      'ukhpi:housePriceIndex' => [1234],
      'ukhpi:averagePrice' => [12_345],
      'ukhpi:percentageChange' => [10],
      'ukhpi:percentageAnnualChange' => [-10]
    }
  end

  def mock_landing_state(data)
    lvc = mock
    lvc.expects(:perform_query)
    lvc.expects(:results).at_least_once.returns(data)

    lv = mock
    lv.expects(:new).returns(lvc)

    LandingState.new(lv)
  end

  it 'returns the result when one is available' do
    ls = mock_landing_state([mock_latest_value_data])

    result_hash = ls.result
    _(result_hash).wont_be_nil
    result_hash.each_key do |k|
      _(k).must_be_kind_of Symbol
    end
  end

  it 'returns nil when no result is available' do
    ls = mock_landing_state([])
    _(ls.result).must_equal({})

    ls = mock_landing_state(nil)
    _(ls.result).must_equal({})
  end

  it 'returns the latest month if defined' do
    ls = mock_landing_state([mock_latest_value_data])
    _(ls.period).must_equal 'January 2016'
  end

  it 'returns an appropriate message if the latest period is not available' do
    ls = mock_landing_state([])
    _(ls.period).must_equal 'Latest period not available'
  end

  it 'returns the latest value of the house price index' do
    ls = mock_landing_state([mock_latest_value_data])
    _(ls.house_price_index).must_equal 1234
  end

  it 'returns the latest value of the average price index' do
    ls = mock_landing_state([mock_latest_value_data])
    _(ls.average_price).must_equal 12_345
  end

  it 'returns the latest value of the monthly change index' do
    ls = mock_landing_state([mock_latest_value_data])
    _(ls.percentage_monthly_change).must_equal 'risen by 10.0%'
  end

  it 'returns the latest value of the annual change index' do
    ls = mock_landing_state([mock_latest_value_data])
    _(ls.percentage_annual_change).must_equal 'fallen by 10.0%'
  end

  it 'notes when prices have stayed the same' do
    ls = mock_landing_state([{ "ukhpi:percentageAnnualChange": [0] }])
    _(ls.percentage_annual_change).must_equal 'remained the same'
  end
end
