# Unit tests on the ExplorationState class

require 'test_helper'

class ExplorationStateTest < ActiveSupport::TestCase

  it "recognises a query command" do
    q = mock()
    q.expects( :"query_command?").at_least_once.returns( true )
    es = ExplorationState.new(q)

    es.query?.must_equal true
    es.empty?.must_equal false
    es.exception?.must_equal false
    es.partial_name( "foo" ).must_equal "query_foo"
  end

  it "recognises a non-query command" do
    q = mock()
    q.expects( :"query_command?").at_least_once.returns( false )
    es = ExplorationState.new(q)

    es.query?.must_equal false
    es.empty?.must_equal false
    es.exception?.must_equal false
    es.partial_name( "foo" ).must_equal "search_foo"
  end

  it "recognises an exception" do
    es = ExplorationState.new( exception: RuntimeError.new )
    es.exception?.must_be_truthy
    es.query?.must_equal false
    es.empty?.must_equal false
    es.partial_name( "foo" ).must_equal "exception_foo"
  end

  it "recognises an empty state" do
    es = ExplorationState.new
    es.exception?.must_equal false
    es.query?.must_equal false
    es.empty?.must_equal true
    es.partial_name( "foo" ).must_equal "empty_state_foo"
  end
end
