# frozen_string_literal: true

# Subscribe to :action_dispatch events
class ActionDispatchPrometheusSubscriber < ActiveSupport::Subscriber
  attach_to :action_dispatch

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def process_action(_event)
    mem = GetProcessMem.new
    Prometheus::Client.registry
                      .get(:memory_used_mb)
                      .set(mem.mb)
    # description: 'Thread is aborting'
    Prometheus::Client.registry
                      .get(:process_threads)
                      .set(
                        Thread.list.select { |thread| thread.status == 'aborting' }.count,
                        labels: {
                          status: 'aborting'
                        }
                      )
    # description: 'Thread is sleeping or waiting on I/O'
    Prometheus::Client.registry
                      .get(:process_threads)
                      .set(
                        Thread.list.select { |thread| thread.status == 'sleep' }.count,
                        labels: {
                          status: 'sleep'
                        }
                      )
    # description: 'Thread is executing'
    Prometheus::Client.registry
                      .get(:process_threads)
                      .set(
                        Thread.list.select { |thread| thread.status == 'run' }.count,
                        labels: {
                          status: 'run'
                        }
                      )
    # description: 'Thread is terminated normally'
    Prometheus::Client.registry
                      .get(:process_threads)
                      .set(
                        Thread.list.select { |thread| thread.status == false }.count,
                        labels: {
                          status: 'false'
                        }
                      )
    # description: 'Thread is terminated with an exception'
    Prometheus::Client.registry
                      .get(:process_threads)
                      .set(
                        Thread.list.select { |thread| thread.status.nil? }.count,
                        labels: {
                          status: 'nil'
                        }
                      )
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
