require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/config/"
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails/capybara"
require "mocha/mini_test"
require "minitest/reporters"
require "vcr"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :faraday
end

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  def assert_well_formed_html( fragment )
    doc = Nokogiri::XML( fragment )
    assert_empty doc.errors
  end
end

module MiniTest::Assertions
  def assert_truthy( proposition )
    assert proposition
  end
  def assert_not_truthy( proposition )
    assert !proposition
  end
end

Object.infect_an_assertion :assert_truthy, :must_be_truthy, :unary
Object.infect_an_assertion :assert_not_truthy, :must_not_be_truthy, :unary
