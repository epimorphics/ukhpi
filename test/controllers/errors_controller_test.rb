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

  test 'unparseable compare selections render the 400 page' do
    get '/compare', params: { from: 'not-a-date' }

    assert_response :bad_request
    assert_includes @response.body, 'Request not understood'
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

    assert_equal [ { exception: { class: 'RuntimeError', action: 'landing#index',
                                  message: 'boom', status: 500, } } ],
                 events
  end

  test 'internal errors are counted by exception class and action, not message' do
    LandingState.stubs(:new).raises(RuntimeError, 'boom')

    assert_difference -> { internal_error_count('Unhandled RuntimeError in landing#index') }, 1 do
      get '/'
    end
  end

  test 'an error raised while rendering a view is counted as its cause' do
    QueryCommand.any_instance.stubs(:perform_query)
    QueryCommand.any_instance.stubs(:results).returns([])
    PrintPresenter.any_instance.stubs(:indicator_summary).raises(NoMethodError, 'nope')

    assert_difference -> { internal_error_count('Unhandled NoMethodError in print#show') }, 1 do
      get '/print'
    end
    assert_response :internal_server_error
  end

  test 'a client error is not counted as an internal error' do
    events = []
    callback = ->(*, payload) { events << payload }

    ActiveSupport::Notifications.subscribed(callback, 'internal_error.application') { get '/nope' }

    assert_empty events
  end

  test 'a malformed query string renders the 400 page' do
    # Set directly: the test helper would reject this URL before it reached the app
    get '/', env: { 'QUERY_STRING' => 'sk=%%_subscriberKey%%' }

    assert_response :bad_request
    assert_includes @response.body, 'Request not understood'
  end

  test 'a malformed form body still renders the error page' do
    post '/this-route-does-not-exist', params: 'sk=%%_subscriberKey%%',
                                       headers: { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' }

    assert_response :not_found
    assert_includes @response.body, 'Page not found'
  end

  test 'an unsupported lang still renders the error page' do
    get '/this-route-does-not-exist?lang=en%5C'

    assert_response :not_found
    assert_includes @response.body, 'Page not found'
  end

  test 'non-HTML requests get a plain text body with the same status' do
    get '/this-route-does-not-exist', headers: { 'Accept' => 'text/plain' }

    assert_response :not_found
    assert_equal 'Not Found', @response.body.strip
  end

  private

  def internal_error_count(label)
    Prometheus::Client.registry
                      .get(:internal_application_error)
                      .get(labels: { message: label })
  end
end
