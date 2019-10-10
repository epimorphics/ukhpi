# frozen_string_literal: true

require 'test_helper'

class MockService
  attr_reader :captured

  def query(query)
    @captured = query.to_json
  end
end

def validate_json(json) # rubocop:disable Metrics/MethodLength
  _(json).must_match_json_expression(
    "@and":
    [
      { "ukhpi:refMonth": {
        "@ge": { "@value": '2015-01', "@type": 'http://www.w3.org/2001/XMLSchema#gYearMonth' }
      } },
      { "ukhpi:refMonth": {
        "@le": { "@value": '2016-06', "@type": 'http://www.w3.org/2001/XMLSchema#gYearMonth' }
      } },
      { "ukhpi:refRegion": {
        "@eq": { "@id": 'http://fubar.com/foo' }
      } }
    ],
    '@sort' => [
      { '@up' => 'ukhpi:refMonth' }
    ]
  )
end

# Unit tests on the QueryCommand class
class QueryCommandTest < ActiveSupport::TestCase
  let(:user_selections) do
    user_selections = mock
    user_selections.expects(:from_date).returns(Date.new(2015, 1, 1))
    user_selections.expects(:to_date).returns(Date.new(2016, 6, 1))
    user_selections.expects(:selected_location).returns('http://fubar.com/foo')
    user_selections
  end

  let(:qc) { QueryCommand.new(user_selections) }

  describe 'QueryCommand' do
    describe '#initialize' do
      it 'constructs a query correctly' do
        json = qc.query.to_json
        _(json).wont_be_nil
        validate_json(json)
      end
    end

    describe '#perform_query' do
      it 'calls the service endpoint correctly' do
        mock_service = MockService.new
        qc.perform_query(mock_service)
        validate_json(mock_service.captured)
      end
    end
  end

  describe '#query_command?' do
    it 'should report its type correctly' do
      assert qc.query_command?
      assert_not qc.explain_query_command?
    end
  end
end
