require 'test_helper'

# Unit tests on the ApiRequestLogSubscriber class
class ApiRequestLogSubscriberTest < ActiveSupport::TestCase
  describe 'ApiRequestLogSubscriber' do
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

      it 'should omit returned_rows when the response body is not an array' do
        url = stub(path: '/landregistry/id/ukhpi', query: nil)
        env = stub(url: url, method: :get)
        response = stub(env: env, status: 200, body: { 'result' => 'ok' })
        event = stub(payload: { response: response, duration: 5 })

        Rails.logger.expects(:info).with(
          {
            message: 'API returned 0 rows, time taken: 5 ms',
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

    # Regression coverage for the event-namespace wiring itself (`attach_to`),
    # matching the equivalent test on ApiPrometheusSubscriber - see that file
    # for why calling #response directly isn't enough on its own.
    describe 'ActiveSupport::Notifications wiring' do
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
    end
  end
end
