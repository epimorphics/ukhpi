# frozen_string_literal: true

prometheus = Prometheus::Client.registry

# Prometheus counters
prometheus.counter(
  :api_status,
  docstring: 'Response from back-end API',
  labels: [:status]
)
prometheus.counter(
  :api_requests,
  docstring: 'Overall count of back-end API requests',
  labels: [:result]
)
prometheus.counter(
  :api_connection_failure,
  docstring: 'Reasons for back-end API connection failure',
  labels: [:message]
)
prometheus.counter(
  :api_service_exception,
  docstring: 'The response from the back-end data API was not processed',
  labels: [:message]
)
prometheus.counter(
  :internal_application_error,
  docstring: 'Unexpected events and internal error count',
  labels: [:message]
)

# Prometheus gauges
prometheus.gauge(
  :memory_used_mb,
  docstring: 'Process memory usage in mb'
)

# Prometheus histograms
prometheus.histogram(
  :api_response_times,
  docstring: 'Histogram of response times for API requests',
  buckets: Prometheus::Client::Histogram.exponential_buckets(start: 0.005, count: 16)
)
