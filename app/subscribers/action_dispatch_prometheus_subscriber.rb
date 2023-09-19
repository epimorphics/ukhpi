# frozen_string_literal: true

# Subscribe to :action_dispatch events
class ActionDispatchPrometheusSubscriber < ActiveSupport::Subscriber
  attach_to :action_dispatch

  def request(_event)
    mem = GetProcessMem.new

    Prometheus::Client.registry
                      .get(:memory_used_mb)
                      .set(mem.mb)
  end
end
