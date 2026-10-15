require 'test_helper'

# Unit tests on the ApiRequestLogSubscriber class
class ApiRequestLogSubscriberTest < ActiveSupport::TestCase
  API_URL = 'http://data-api:8080'.freeze
  QUERY_PATH = '/landregistry/id/ukhpi?_limit=1'.freeze

  describe 'ApiRequestLogSubscriber' do
    before do
      Rails.application.config.stubs(:api_service_url).returns(API_URL)
    end

    describe '#request' do
      it 'should log the method and full path including the query string' do
        event = stub(payload: { path: '/landregistry/id/ukhpi', method: 'GET', query_string: '_limit=1' })

        Rails.logger.expects(:info).with(
          {
            message: "Calling API: GET #{QUERY_PATH}",
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: QUERY_PATH,
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.request(event)
      end

      it 'should omit the query string when absent' do
        event = stub(payload: { path: '/landregistry/id/ukhpi', method: 'POST', query_string: nil })

        Rails.logger.expects(:info).with(
          {
            message: 'Calling API: POST /landregistry/id/ukhpi',
            upstream_url: API_URL,
            upstream_method: 'POST',
            upstream_path: '/landregistry/id/ukhpi',
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.request(event)
      end

      it 'should log GET when the gem gives no method' do
        event = stub(payload: { path: '/landregistry/id/ukhpi', query_string: '_limit=1' })

        Rails.logger.expects(:info).with(
          {
            message: "Calling API: GET #{QUERY_PATH}",
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: QUERY_PATH,
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.request(event)
      end
    end

    describe '#response' do
      it 'should log the status, row count, path and timing for a successful response' do
        url = stub(path: '/landregistry/id/ukhpi', query: 'refRegion=uk&_limit=1')
        env = stub(url: url, method: :get)
        response = stub(env: env, status: 200, body: [ { 'refMonth' => '2024-01' } ])
        event = stub(payload: { response: response, duration: 1233 })

        Rails.logger.expects(:info).with(
          {
            message: 'API returned 1 row for GET /landregistry/id/ukhpi?refRegion=uk&_limit=1 (status 200, 1.233s)',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi?refRegion=uk&_limit=1',
            upstream_status: 200,
            upstream_time: 1.233,
            returned_rows: 1,
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.response(event)
      end

      it 'should pluralise the row count and omit the query string when absent' do
        url = stub(path: '/landregistry/id/ukhpi', query: nil)
        env = stub(url: url, method: :get)
        response = stub(env: env, status: 200, body: [ {}, {} ])
        event = stub(payload: { response: response, duration: 42 })

        Rails.logger.expects(:info).with(
          {
            message: 'API returned 2 rows for GET /landregistry/id/ukhpi (status 200, 0.042s)',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi',
            upstream_status: 200,
            upstream_time: 0.042,
            returned_rows: 2,
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.response(event)
      end

      it 'should omit returned_rows and not claim a row count when the response body is not an array' do
        url = stub(path: '/landregistry/id/ukhpi', query: nil)
        env = stub(url: url, method: :get)
        response = stub(env: env, status: 200, body: { 'result' => 'ok' })
        event = stub(payload: { response: response, duration: 5 })

        Rails.logger.expects(:info).with(
          {
            message: 'API responded to GET /landregistry/id/ukhpi (status 200, 0.005s)',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi',
            upstream_status: 200,
            upstream_time: 0.005,
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.response(event)
      end
    end

    describe '#retry' do
      it 'should log a warning with the exception, path, method and retry timing' do
        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')
        event = stub(
          payload: {
            path: '/landregistry/id/ukhpi',
            method: 'GET',
            retry_count: 2,
            exception: exception,
            will_retry_in: 1.084,
          }
        )

        Rails.logger.expects(:warn).with(
          {
            message: 'Retrying API request GET /landregistry/id/ukhpi in 1.08s (attempt 2): ' \
                     'Failed to open TCP connection to data-api:8080',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi',
            retry_count: 2,
            exception: 'Faraday::ConnectionFailed',
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.retry(event)
      end
    end

    describe '#connection_failure' do
      it 'should log a warning with no status, ignoring the one the gem sends' do
        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')
        event = stub(
          payload: {
            exception: exception, path: '/landregistry/id/ukhpi', query_string: '_limit=1', duration: 10, status: 503,
          }
        )

        Rails.logger.expects(:error).never
        Rails.logger.expects(:warn).with(
          {
            message: "Could not connect to the API for GET #{QUERY_PATH} (0.01s): " \
                     'Failed to open TCP connection to data-api:8080',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: QUERY_PATH,
            upstream_time: 0.01,
            exception: 'Faraday::ConnectionFailed',
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.connection_failure(event)
      end
    end

    describe '#service_exception' do
      it 'should log a warning with the status the API returned' do
        exception = DataServicesApi::ServiceException.new('the server responded with status 503', 503)
        event = stub(
          payload: {
            exception: exception, path: '/landregistry/id/ukhpi', query_string: '_limit=1', duration: 12, status: 503,
          }
        )

        Rails.logger.expects(:error).never
        Rails.logger.expects(:warn).with(
          {
            message: "API returned an error for GET #{QUERY_PATH} (status 503, 0.012s)",
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: QUERY_PATH,
            upstream_status: 503,
            upstream_time: 0.012,
            exception: 'DataServicesApi::ServiceException',
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.service_exception(event)
      end

      it 'should describe the exception when the API gave no status' do
        exception = DataServicesApi::ServiceException.new('unexpected token', nil)
        event = stub(
          payload: {
            exception: exception, path: '/landregistry/id/ukhpi', query_string: nil, duration: 12, status: nil,
          }
        )

        Rails.logger.expects(:warn).with(
          {
            message: 'API response to GET /landregistry/id/ukhpi could not be read (0.012s): unexpected token',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi',
            upstream_time: 0.012,
            exception: 'DataServicesApi::ServiceException',
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.service_exception(event)
      end
    end

    describe 'upstream_url' do
      def logged_upstream_url(api_service_url)
        Rails.application.config.stubs(:api_service_url).returns(api_service_url)
        logged = nil
        Rails.logger.stubs(:info).with { |entry| logged = entry }

        ApiRequestLogSubscriber.new.request(stub(payload: { path: '/landregistry/id/ukhpi' }))
        logged.fetch(:upstream_url, :absent)
      end

      it 'should be the scheme, host and port of the configured API' do
        assert_equal 'http://data-api:8080', logged_upstream_url('http://data-api:8080/some/path')
      end

      it 'should leave out the default port' do
        assert_equal 'https://data-api.example', logged_upstream_url('https://data-api.example:443/')
      end

      it 'should be absent when no API is configured' do
        assert_equal :absent, logged_upstream_url(nil)
      end

      it 'should be the configured value when it cannot be parsed' do
        assert_equal 'http://local host:8888', logged_upstream_url('http://local host:8888')
        assert_equal 'localhost:8888', logged_upstream_url('localhost:8888')
      end
    end

    # Regression coverage for the event-namespace wiring itself (`attach_to`),
    # matching the equivalent test on ApiPrometheusSubscriber. The specs above
    # call the handlers directly, so they pass regardless of what `attach_to`
    # names; these fire through the real notification bus.
    describe 'ActiveSupport::Notifications wiring' do
      it 'invokes #request when request.data_services_api fires' do
        Rails.logger.expects(:info).with(
          {
            message: "Calling API: GET #{QUERY_PATH}",
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: QUERY_PATH,
            request_status: 'processing',
          }
        )

        ActiveSupport::Notifications.instrument(
          'request.data_services_api',
          path: '/landregistry/id/ukhpi',
          query_string: '_limit=1'
        )
      end

      it 'invokes #response when response.data_services_api fires' do
        url = stub(path: '/landregistry/id/ukhpi', query: nil)
        env = stub(url: url, method: :get)
        response = stub(env: env, status: 200, body: [ {} ])

        Rails.logger.expects(:info).with(
          {
            message: 'API returned 1 row for GET /landregistry/id/ukhpi (status 200, 0.01s)',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi',
            upstream_status: 200,
            upstream_time: 0.01,
            returned_rows: 1,
            request_status: 'processing',
          }
        )

        ActiveSupport::Notifications.instrument('response.data_services_api', response: response, duration: 10)
      end

      it 'invokes #retry when retry.data_services_api fires' do
        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')

        Rails.logger.expects(:warn).with(
          {
            message: 'Retrying API request GET /landregistry/id/ukhpi in 0.5s (attempt 1): ' \
                     'Failed to open TCP connection to data-api:8080',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi',
            retry_count: 1,
            exception: 'Faraday::ConnectionFailed',
            request_status: 'processing',
          }
        )

        ActiveSupport::Notifications.instrument(
          'retry.data_services_api',
          path: '/landregistry/id/ukhpi',
          method: 'GET',
          retry_count: 1,
          exception: exception,
          will_retry_in: 0.5
        )
      end

      it 'invokes #connection_failure when connection_failure.data_services_api fires' do
        exception = Faraday::TimeoutError.new('timeout')

        Rails.logger.expects(:warn).with(
          {
            message: 'API did not respond in time to GET /landregistry/id/ukhpi (0.5s): timeout',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi',
            upstream_time: 0.5,
            exception: 'Faraday::TimeoutError',
            request_status: 'processing',
          }
        )

        ActiveSupport::Notifications.instrument(
          'connection_failure.data_services_api',
          exception: exception, path: '/landregistry/id/ukhpi', query_string: nil, duration: 500, status: 503
        )
      end

      it 'invokes #service_exception when service_exception.data_services_api fires' do
        exception = DataServicesApi::ServiceException.new('the server responded with status 500', 500)

        Rails.logger.expects(:warn).with(
          {
            message: 'API returned an error for GET /landregistry/id/ukhpi (status 500, 0.02s)',
            upstream_url: API_URL,
            upstream_method: 'GET',
            upstream_path: '/landregistry/id/ukhpi',
            upstream_status: 500,
            upstream_time: 0.02,
            exception: 'DataServicesApi::ServiceException',
            request_status: 'processing',
          }
        )

        ActiveSupport::Notifications.instrument(
          'service_exception.data_services_api',
          exception: exception, path: '/landregistry/id/ukhpi', query_string: nil, duration: 20, status: 500
        )
      end
    end
  end
end
