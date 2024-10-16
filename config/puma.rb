# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS', max_threads_count)
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests;
# default is 3000.
port ENV.fetch('PORT', 3000)

# Specifies the `metrics_port` that Puma will listen on to export metrics;
# default is 9393.
# metrics_port = ENV.fetch('METRICS_PORT', 9393)

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch('RAILS_ENV', 'development')

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
# preload_app!

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
#
# on_worker_boot do
#   ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
# end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Uncomment the following line once ruby is updated to 2.7 or greater to allow
# the use of the puma-metrics plugin as we're using puma 6.0.0 or greater
# Additional metrics from the Puma server to be exposed in the /metrics endpoint
# plugin :metrics
# Bind the metric server to "url". "tcp://" is the only accepted protocol.
# metrics_url "tcp://0.0.0.0:#{metrics_port}" if Rails.env.development?

# Use a custom log formatter to emit Puma log messages in a JSON format
log_formatter do |str|
  {
    ts: DateTime.now.utc.strftime('%FT%T.%3NZ'),
    level: 'INFO',
    message: str
  }.to_json
end
