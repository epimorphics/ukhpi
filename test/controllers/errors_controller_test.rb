require 'test_helper'

# Error pages are reached only through `config.exceptions_app`, so these tests
# cause real errors and check what the middleware renders. They assert on status
# as well as body: asserting only on the body is what let a 200 serving a 404 page
# go unnoticed before.
class ErrorsControllerTest < ActionDispatch::IntegrationTest
  # The suite runs with `show_exceptions = :none`, so that controller exceptions
  # fail tests with a backtrace. These tests need the exceptions middleware on,
  # and detailed exceptions off: `consider_all_requests_local` is true in test,
  # so otherwise Rails renders its own debug page and never reaches ErrorsController.
  setup do
    env = Rails.application.env_config
    @original_env = env.slice('action_dispatch.show_exceptions', 'action_dispatch.show_detailed_exceptions')
    env['action_dispatch.show_exceptions'] = :all
    env['action_dispatch.show_detailed_exceptions'] = false
  end

  teardown do
    Rails.application.env_config.merge!(@original_env)
  end

  test 'an unmatched path renders the 404 page' do
    get '/this-route-does-not-exist'

    assert_response :not_found
    assert_includes @response.body, 'Page not found'
  end

  test 'error pages cannot be requested directly' do
    get '/500'

    assert_response :not_found
  end

  test 'invalid selections render the 400 page listing what was wrong' do
    get '/browse', params: { from: 'not-a-date' }

    assert_response :bad_request
    assert_includes @response.body, 'Request not understood'
    assert_includes @response.body, 'incorrect or missing &quot;from&quot; date'
  end

  test 'an unhandled exception renders the 500 page' do
    LandingState.stubs(:new).raises(RuntimeError, 'boom')

    get '/'

    assert_response :internal_server_error
    assert_includes @response.body, 'Application error'
  end

  test 'an unhandled exception is counted as an internal error' do
    LandingState.stubs(:new).raises(RuntimeError, 'boom')
    events = []
    callback = ->(*, payload) { events << payload }

    ActiveSupport::Notifications.subscribed(callback, 'internal_error.application') { get '/' }

    assert_equal [ { exception: { message: 'boom', status: 500 } } ], events
  end

  test 'a client error is not counted as an internal error' do
    events = []
    callback = ->(*, payload) { events << payload }

    ActiveSupport::Notifications.subscribed(callback, 'internal_error.application') { get '/nope' }

    assert_empty events
  end

  test 'non-HTML requests get a plain text body with the same status' do
    get '/this-route-does-not-exist', headers: { 'Accept' => 'text/plain' }

    assert_response :not_found
    assert_equal 'Not Found', @response.body.strip
  end
end
