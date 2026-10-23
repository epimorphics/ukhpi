require 'test_helper'
require 'sentry/test_helper'

# Requests naming an indicator, statistic, theme, location or date we don't recognise
# are the user's mistake, so they get a 400, not a 500. Each case is a request seen
# in production (#676). The API is stubbed: these requests must be rejected before
# any query is made.
class InvalidSelectionsTest < ActionDispatch::IntegrationTest
  include Sentry::TestHelper

  UK = 'http://landregistry.data.gov.uk/id/region/united-kingdom'.freeze
  DATES = { from: '2022-01-01', to: '2023-01-01' }.freeze

  # Error pages need the exceptions middleware on: see ErrorsControllerTest
  setup do
    env = Rails.application.env_config
    @original_env = env.slice('action_dispatch.show_exceptions', 'action_dispatch.show_detailed_exceptions')
    env['action_dispatch.show_exceptions'] = :all
    env['action_dispatch.show_detailed_exceptions'] = false

    QueryCommand.any_instance.stubs(:perform_query)
    QueryCommand.any_instance.stubs(:results).returns([])
  end

  teardown do
    Rails.application.env_config.merge!(@original_env)
  end

  {
    'download with an unknown indicator' =>
      [ '/download/new.csv', { 'in[]' => 'pc', 'thm[]' => 'property_type', location: UK } ],
    'download with an unknown theme' =>
      [ '/download/new.csv', { 'in[]' => 'avg', 'thm[]' => 'sales_volume', location: UK } ],
    'download with location slugs instead of GSS codes' =>
      [ '/download/new.csv', { 'location[]' => 'england' } ],
    'print with an unknown indicator' =>
      [ '/print', { 'in[]' => 'index', 'thm[]' => 'property_type', location: UK } ],
    'print with an unknown theme' =>
      [ '/print', { 'in[]' => 'avg', 'thm[]' => 'average_price', location: UK } ],
    'print with an unknown location' =>
      [ '/print', { location: 'http://landregistry.data.gov.uk/id/region/nowhere' } ],
    'compare with an unknown indicator' =>
      [ '/compare', { in: 'average_price' } ],
    'compare with a blank indicator' =>
      [ '/compare', { in: '' } ],
    'compare print with an unknown statistic' =>
      [ '/compare', { print: 'true', 'location[]' => 'E12000007', st: 'semi-detached', in: 'avg' } ],
    'browse edit with a blank date' =>
      [ '/browse/edit', { from: '' } ],
  }.each do |description, (path, params)|
    test "#{description} is a bad request" do
      get path, params: DATES.merge(params)

      assert_response :bad_request
    end
  end

  # A bad request is the user's mistake, not a bug, so it is not reported to Sentry
  # (#706). Sentry also records a sample of requests as performance transactions,
  # which are not errors, so only error events are checked, by exception class.
  test 'a bad request is not reported to Sentry' do
    setup_sentry_test

    get '/browse', params: DATES.merge('thm[]' => 'average_price', location: UK)

    assert_response :bad_request
    assert_empty(sentry_events.grep(Sentry::ErrorEvent).map { |event| event.exception.values.last.type })
  ensure
    teardown_sentry_test
  end

  test 'the error page lists what was not recognised' do
    get '/print', params: DATES.merge('thm[]' => 'average_price', location: UK)

    assert_includes @response.body, 'unrecognised theme(s)'
  end
end
