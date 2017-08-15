# frozen_string_literal: true

# Unit tests on the UserPreferences class

require 'test_helper'

class UserPreferencesTest < ActiveSupport::TestCase
  it 'permits access to whitelisted parameters' do
    up = UserPreferences.new('region' => 'foo')
    up.region.must_equal 'foo'
    up.from.wont_be_nil
    up.to.wont_be_nil
  end

  it 'returns nil for non-whitelist parameters' do
    up = UserPreferences.new('region' => 'foo')
    up.womble.must_not_be_truthy
  end

  it 'provides a default value for region' do
    up = UserPreferences.new('region' => '')
    up.region.wont_be_nil
    up.region.start_with?('http:')
  end

  it 'accepts valid dates' do
    up = UserPreferences.new('from' => '2015-01-01', 'to' => '2016-01-01')
    up.from.must_be_kind_of Date
    up.to.must_be_kind_of Date
    (up.from < up.to).must_equal true
  end

  it 'rejects invalid dates' do
    lambda {
      UserPreferences.new('from' => 'century of the fruitbat')
    }.must_raise ArgumentError
  end

  it 'provides a default date' do
    up = UserPreferences.new('region' => 'foo', 'from' => '', 'to' => '')
    up.from.must_be_kind_of Date
    up.to.must_be_kind_of Date
  end

  it 'allows a parameter to be set' do
    up = UserPreferences.new('region' => 'foo')
    up0 = up.with(:region, 'bar')
    up.region.must_equal 'foo'
    up0.region.must_equal 'bar'
  end

  it 'provides a default selection for aspect indicators' do
    up = UserPreferences.new('ai' => '')
    up.aspect_indicators.wont_be_nil
    up.aspect_indicators.length.must_equal 4
  end

  it 'provides a default selection for aspect categories' do
    up = UserPreferences.new('ac' => '')
    up.aspect_categories.wont_be_nil
    up.aspect_categories.length.must_equal 1
    up.aspect_categories.first.must_equal ''
  end

  it 'reports selected aspect indicators as an array' do
    up = UserPreferences.new('ai' => %w[foo bar])
    up.aspect_indicators.must_be_kind_of Array
    up.aspect_indicators.first.must_equal :foo
    up.aspect_indicators.second.must_equal :bar
    up.aspect_indicators.length.must_equal 2
  end

  it 'decodes selected aspect indicators as an array' do
    up = UserPreferences.new('ai' => 'foo,bar')
    up.aspect_indicators.must_be_kind_of Array
    up.aspect_indicators.first.must_equal :foo
    up.aspect_indicators.second.must_equal :bar
    up.aspect_indicators.length.must_equal 2
  end

  it 'wraps a single aspect indicator as an array' do
    up = UserPreferences.new('ai' => 'foo')
    up.aspect_indicators.must_be_kind_of Array
    up.aspect_indicators.first.must_equal :foo
    up.aspect_indicators.length.must_equal 1
  end

  it 'can encode parameters as a URL search string' do
    UserPreferences
      .new('region' => 'foo', 'from' => '2016-04')
      .as_search_string
      .must_equal 'from=2016-04-01&region=foo'
  end

  it 'can encode array-valued parameters as a search string' do
    UserPreferences
      .new('ai' => %w[foo bar])
      .as_search_string
      .must_equal 'ai=foo,bar'
  end

  it 'should return itself when asked for preferences' do
    up = UserPreferences.new({})
    up.prefs.must_be_same_as up
  end

  it 'should summarise itself' do
    up = UserPreferences.new('region' => 'foo')
    up.summary.must_equal('foo')

    up1 = UserPreferences.new('region' => 'foo', 'to' => '2016-01-01')
    up1.summary.must_equal('foo to January 2016')
  end

  it 'should correctly summarise a URI valued location' do
    up = UserPreferences.new('region' => 'http://landregistry.data.gov.uk/id/region/great-britain')
    up.summary.must_equal('Great Britain')
  end
end
