require 'test_helper'

# Unit tests on the ApiPrometheusSubscriber class
class ApiPrometheusSubscriberTest < ActiveSupport::TestCase
  describe 'ApiPrometheusSubscriber' do
    describe '#connection_failure' do
      it 'should increment the failure counters and log an error' do
        exception = Faraday::ConnectionFailed.new('Failed to open TCP connection to data-api:8080')
        event = stub(payload: { exception: exception })

        Prometheus::Client.registry.get(:api_requests).expects(:increment).with(labels: { result: 'failure' })
        Prometheus::Client.registry.get(:api_connection_failure).expects(:increment)
          .with(labels: { message: exception.to_s })
        Log.expects(:error).with(
          "API connection failure: #{exception.message}",
          { error_class: 'Faraday::ConnectionFailed', status: 503 }
        )

        ApiPrometheusSubscriber.new.connection_failure(event)
      end
    end

    describe '#service_exception' do
      it 'should increment the exception counter and log an error' do
        exception = StandardError.new('Unexpected response from data-api')
        event = stub(payload: { exception: exception })

        Prometheus::Client.registry.get(:api_service_exception).expects(:increment)
          .with(labels: { message: exception.to_s })
        Log.expects(:error).with(
          "API service exception: #{exception.message}",
          { error_class: 'StandardError', status: 502 }
        )

        ApiPrometheusSubscriber.new.service_exception(event)
      end
    end
  end
end
