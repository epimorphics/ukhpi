require 'test_helper'

# Unit tests on the ApiPrometheusSubscriber class
class ApiPrometheusSubscriberTest < ActiveSupport::TestCase
  describe 'ApiPrometheusSubscriber' do
    describe '#connection_failure' do
      it 'should increment the failure counters' do
        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')
        event = stub(payload: { exception: exception })

        Prometheus::Client.registry.get(:api_requests).expects(:increment).with(labels: { result: 'failure' })
        Prometheus::Client.registry.get(:api_connection_failure).expects(:increment)
          .with(labels: { message: exception.to_s })

        ApiPrometheusSubscriber.new.connection_failure(event)
      end
    end

    describe '#service_exception' do
      it 'should increment the exception counter' do
        exception = StandardError.new('Unexpected response from data-api')
        event = stub(payload: { exception: exception })

        Prometheus::Client.registry.get(:api_service_exception).expects(:increment)
          .with(labels: { message: exception.to_s })

        ApiPrometheusSubscriber.new.service_exception(event)
      end
    end

    # Regression coverage for the event-namespace wiring itself (`attach_to`).
    # The specs above call the subscriber's methods directly, so they'd still
    # pass even if `attach_to` named the wrong event prefix - as happened
    # silently when data_services_api 2.0.0 renamed its events from `*.api`
    # to `*.data_services_api`. These fire through the real notification bus
    # so a future rename would fail here instead of going unnoticed.
    describe 'ActiveSupport::Notifications wiring' do
      it 'invokes #connection_failure when connection_failure.data_services_api fires' do
        # Force the subscriber class to load (and so attach_to to run) before firing the
        # notification - Zeitwerk autoloads it lazily since nothing else references it by
        # name, so without this the test's pass/fail depends on random test ordering.
        ApiPrometheusSubscriber

        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')

        Prometheus::Client.registry.get(:api_requests).expects(:increment).with(labels: { result: 'failure' })
        Prometheus::Client.registry.get(:api_connection_failure).expects(:increment)
          .with(labels: { message: exception.to_s })

        ActiveSupport::Notifications.instrument('connection_failure.data_services_api', exception: exception)
      end

      it 'invokes #service_exception when service_exception.data_services_api fires' do
        ApiPrometheusSubscriber

        exception = StandardError.new('Unexpected response from data-api')

        Prometheus::Client.registry.get(:api_service_exception).expects(:increment)
          .with(labels: { message: exception.to_s })

        ActiveSupport::Notifications.instrument('service_exception.data_services_api', exception: exception)
      end
    end
  end
end
