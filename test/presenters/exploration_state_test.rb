# Unit tests on the ExplorationState class

require 'test_helper'

class ExplorationStateTest < ActiveSupport::TestCase

  it "recognises a query command" do
    q = mock()
    q.expects( :"query_command?").returns( true )
    non_q = mock()
    non_q.expects( :"query_command?").returns( false )

    ExplorationState.new(q).query?.must_equal true
    ExplorationState.new(non_q).query?.must_equal false
  end

  it "recognises an exception" do
    es = ExplorationState.new( exception: RuntimeError.new )
    es.exception?.must_be_truthy
    es.query?.must_equal false
    es.empty?.must_equal false
  end

  it "recognises an empty state" do
    es = ExplorationState.new
    es.exception?.must_equal false
    es.query?.must_equal false
    es.empty?.must_equal true
  end
end
