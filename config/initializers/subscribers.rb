# ActiveSupport::Subscriber.attach_to only runs when the subscriber class is
# first loaded. These classes are purely event-driven, so nothing else
# references them by name, and eager loading is off in development and test.
# Without this they may never load outside production: API logging and metrics
# would silently do nothing locally, with no error and nothing to notice.
#
# to_prepare rather than a plain reference, so they re-attach after each reload
# in development.
Rails.application.config.to_prepare do
  ApiRequestLogSubscriber
  ApiPrometheusSubscriber
  ApplicationPrometheusSubscriber
  ActionControllerPrometheusSubscriber
end
