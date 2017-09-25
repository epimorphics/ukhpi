# frozen_string_literal: true

require 'test_helper'

class MockService
  attr_reader :captured

  def explain(_query)
    @captured = { explain_called: true }
  end
end

# Unit tests on the QueryCommand class
class QueryCommandTest < ActiveSupport::TestCase
  let :user_selections do
    user_selections = mock
    user_selections.expects(:from_date).returns(Date.new(2015, 1, 1))
    user_selections.expects(:to_date).returns(Date.new(2016, 6, 1))
    user_selections.expects(:selected_region).returns('http://fubar.com/foo')
    user_selections
  end

  let :eqc { ExplainQueryCommand.new(user_selections) }

  describe 'QueryCommand' do
    describe '#initialize' do
      it 'constructs a query correctly' do
        eqc.query.to_json.wont_be_nil
      end
    end

    describe '#perform_query' do
      it 'calls the service endpoint correctly' do
        mock_service = MockService.new
        eqc.perform_query(mock_service)
        assert mock_service.captured[:explain_called]
      end
    end
  end

  describe '#query_command?' do
    it 'should report its type correctly' do
      refute eqc.query_command?
      assert eqc.explain_query_command?
    end
  end
end
