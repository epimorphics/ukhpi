# frozen_string_literal: true

require 'test_helper'

Struct.new('MockUriValue', :uri)

# Unit tests on the SearchCommand class
class SearchCommandTest < ActiveSupport::TestCase
  it 'delegates to the decorated preferences object' do
    prefs = mock
    prefs.expects(:foo)

    sc = SearchCommand.new(prefs, nil)
    sc.foo
  end

  it 'recognises a search term that is a valid location URI' do
    prefs = UserPreferences.new(ActionController::Parameters.new(region: 'http://foo.bar'))
    regions = mock
    regions.expects(:lookup_region)
           .with('http://foo.bar')
           .returns(Struct::MockUriValue.new('http://foo.bar'))

    sc = SearchCommand.new(prefs, regions)
    sc.search_status.must_equal :single_result
    sc.region.must_equal 'http://foo.bar'
  end

  it 'recognises a search term that matches one location' do
    prefs = UserPreferences.new(ActionController::Parameters.new(region: 'foo'))
    regions = mock
    regions.expects(:match)
           .with { |term, _up| term == 'foo' }
           .returns('http://foo.bar' => Struct::MockUriValue.new('http://foo.bar'))

    sc = SearchCommand.new(prefs, regions)
    sc.search_status.must_equal :single_result
    sc.region_uri.must_equal 'http://foo.bar'
  end

  it 'recognises a search term that does not match any results' do
    prefs = mock
    prefs.expects(:region).at_least_once.returns('foo')

    regions = mock
    regions.expects(:match)
           .with { |term, _up| term == 'foo' }
           .returns({})

    sc = SearchCommand.new(prefs, regions)
    sc.search_status.must_equal :no_results
  end

  it 'recognises a search term that matches many results' do
    prefs = UserPreferences.new(ActionController::Parameters.new(region: 'foo'))
    regions = mock
    regions.expects(:match)
           .with { |term, _up| term == 'foo' }
           .returns('http://foo.bar' => Struct::MockUriValue.new('http://foo.bar'),
                    'http://foo.1.bar' => Struct::MockUriValue.new('http://foo.1.bar'))

    sc = SearchCommand.new(prefs, regions)
    sc.search_status.must_equal :multiple_results
  end

  it 'should state that it is not a query command' do
    SearchCommand.new({}, nil).query_command?.must_equal false
  end
end
