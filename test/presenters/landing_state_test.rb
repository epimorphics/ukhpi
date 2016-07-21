# Unit tests on the LandingState class

require 'test_helper'

class LandingStateTest < ActiveSupport::TestCase

  def mock_latest_value_data
    {

    }
  end

  def mock_landing_state( data )
    lvc = mock()
    lvc.expects( :perform_query )
    lvc.expects( :results ).at_least_once.returns( data )

    lv = mock()
    lv.expects( :new ).returns( lvc )

    LandingState.new(lv)
  end

  it "returns the result when one is available" do
    ls = mock_landing_state( [mock_latest_value_data])

    result_hash = ls.result
    result_hash.wont_be_nil
    result_hash.keys.each do |k|
      k.must_be_kind_of Symbol
    end
  end

  it "returns nil when no result is available" do
    ls = mock_landing_state( [] )
    ls.result.must_equal Hash.new

    ls = mock_landing_state( nil )
    ls.result.must_equal Hash.new
  end
end
