# Subscribe to :application events
class ApplicationPrometheusSubscriber < ActiveSupport::Subscriber
  attach_to :application

  # The label names the exception class and the action that raised it, such as
  # "Unhandled NoMethodError in print#show". The exception's own message is left
  # out: it can carry user input, and every distinct label value is a new time
  # series. The message is in the logs and Sentry.
  #
  # The label is called `message` because the shared ApplicationInternalError alert
  # rule (master-ansible-deployment) shows `{{ $labels.message }}`.
  def internal_error(event)
    Prometheus::Client.registry
                      .get(:internal_application_error)
                      .increment(labels: { message: label(event.payload[:exception]) })
  end

  private

  def label(exception)
    label = "Unhandled #{exception[:class]}"
    exception[:action] ? "#{label} in #{exception[:action]}" : label
  end
end
