require 'test_helper'

# Unit tests on the ApiRequestLogSubscriber class
class ApiRequestLogSubscriberTest < ActiveSupport::TestCase
  describe 'ApiRequestLogSubscriber' do
    describe '#request' do
      it 'should log the method and full path including the query string' do
        event = stub(payload: { path: '/landregistry/id/ukhpi', method: 'GET', query_string: '_limit=1' })

        Rails.logger.expects(:info).with(
          {
            message: 'Calling API: GET /landregistry/id/ukhpi?_limit=1',
            method: 'GET',
            path: '/landregistry/id/ukhpi?_limit=1',
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
            method: 'POST',
            path: '/landregistry/id/ukhpi',
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.request(event)
      end
    end

    describe '#response' do
      it 'should log the row count, path and timing for a successful response' do
        url = stub(path: '/landregistry/id/ukhpi', query: 'refRegion=uk&_limit=1')
        env = stub(url: url, method: :get)
        response = stub(env: env, status: 200, body: [ { 'refMonth' => '2024-01' } ])
        event = stub(payload: { response: response, duration: 1233 })

        Rails.logger.expects(:info).with(
          {
            message: 'API returned 1 row, time taken: 1233 ms',
            method: 'GET',
            path: '/landregistry/id/ukhpi?refRegion=uk&_limit=1',
            request_status: 'processing',
            request_time: '1.233',
            returned_rows: 1,
            status: 200,
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
            message: 'API returned 2 rows, time taken: 42 ms',
            method: 'GET',
            path: '/landregistry/id/ukhpi',
            request_status: 'processing',
            request_time: '0.042',
            returned_rows: 2,
            status: 200,
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
            message: 'API responded, time taken: 5 ms',
            method: 'GET',
            path: '/landregistry/id/ukhpi',
            request_status: 'processing',
            request_time: '0.005',
            status: 200,
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
            message: 'Retrying API request after Faraday::ConnectionFailed: ' \
                      'Failed to open TCP connection to data-api:8080 (attempt 2, retrying in 1.08s)',
            method: 'GET',
            path: '/landregistry/id/ukhpi',
            request_status: 'processing',
          }
        )

        ApiRequestLogSubscriber.new.retry(event)
      end
    end

    describe '#connection_failure' do
      it 'should log an error' do
        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')
        event = stub(payload: { exception: exception })

        Rails.logger.expects(:error).with(
          {
            message: "API connection failure: #{exception.message} - Faraday::ConnectionFailed",
            request_status: 'processing',
            status: 503,
          }
        )

        ApiRequestLogSubscriber.new.connection_failure(event)
      end
    end

    describe '#service_exception' do
      it 'should log an error' do
        exception = StandardError.new('Unexpected response from data-api')
        event = stub(payload: { exception: exception })

        Rails.logger.expects(:error).with(
          {
            message: "API service exception: #{exception.message} - StandardError",
            request_status: 'processing',
            status: 502,
          }
        )

        ApiRequestLogSubscriber.new.service_exception(event)
      end
    end

    # Regression coverage for the event-namespace wiring itself (`attach_to`),
    # matching the equivalent test on ApiPrometheusSubscriber - see that file
    # for why calling #response directly isn't enough on its own.
    describe 'ActiveSupport::Notifications wiring' do
      it 'invokes #request when request.data_services_api fires' do
        ApiRequestLogSubscriber

        Rails.logger.expects(:info).with(
          {
            message: 'Calling API: GET /landregistry/id/ukhpi?_limit=1',
            method: 'GET',
            path: '/landregistry/id/ukhpi?_limit=1',
            request_status: 'processing',
          }
        )

        ActiveSupport::Notifications.instrument(
          'request.data_services_api',
          path: '/landregistry/id/ukhpi',
          method: 'GET',
          query_string: '_limit=1'
        )
      end

      it 'invokes #response when response.data_services_api fires' do
        # Force the subscriber class to load (and so attach_to to run) before firing the
        # notification - Zeitwerk autoloads it lazily since nothing else references it by
        # name, so without this the test's pass/fail depends on random test ordering.
        ApiRequestLogSubscriber

        url = stub(path: '/landregistry/id/ukhpi', query: nil)
        env = stub(url: url, method: :get)
        response = stub(env: env, status: 200, body: [ {} ])

        Rails.logger.expects(:info).with(
          {
            message: 'API returned 1 row, time taken: 10 ms',
            method: 'GET',
            path: '/landregistry/id/ukhpi',
            request_status: 'processing',
            request_time: '0.010',
            returned_rows: 1,
            status: 200,
          }
        )

        ActiveSupport::Notifications.instrument('response.data_services_api', response: response, duration: 10)
      end

      it 'invokes #retry when retry.data_services_api fires' do
        ApiRequestLogSubscriber

        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')

        Rails.logger.expects(:warn).with(
          {
            message: 'Retrying API request after Faraday::ConnectionFailed: ' \
                      'Failed to open TCP connection to data-api:8080 (attempt 1, retrying in 0.5s)',
            method: 'GET',
            path: '/landregistry/id/ukhpi',
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
        ApiRequestLogSubscriber

        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')

        Rails.logger.expects(:error).with(
          {
            message: "API connection failure: #{exception.message} - Faraday::ConnectionFailed",
            request_status: 'processing',
            status: 503,
          }
        )

        ActiveSupport::Notifications.instrument('connection_failure.data_services_api', exception: exception)
      end

      it 'invokes #service_exception when service_exception.data_services_api fires' do
        ApiRequestLogSubscriber

        exception = StandardError.new('Unexpected response from data-api')

        Rails.logger.expects(:error).with(
          {
            message: "API service exception: #{exception.message} - StandardError",
            request_status: 'processing',
            status: 502,
          }
        )

        ActiveSupport::Notifications.instrument('service_exception.data_services_api', exception: exception)
      end
    end
  end
end
