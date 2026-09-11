# Base class for errors that the application raises deliberately, as opposed to
# unexpected exceptions.
#
# Raising one of these is how a controller asks for an error page. Rails maps the
# subclass to an HTTP status via `config.action_dispatch.rescue_responses` in
# config/application.rb, then re-dispatches to ErrorsController through
# `config.exceptions_app`. The application does not choose the status itself.
#
# `user_selections` is carried so the error page can show the user what it made of
# their request. It is read back off the exception in ErrorsController via the
# `action_dispatch.exception` request header.
class ApplicationRequestError < StandardError
  attr_reader :user_selections

  def initialize(message = nil, user_selections: nil)
    @user_selections = user_selections
    super(message)
  end

  # Validation messages to show on the error page, when the selections carry any.
  # Not every selections object has errors, so this is the single place that knows
  # the difference, rather than every caller and the view.
  def errors
    return [] unless user_selections.respond_to?(:errors)

    Array(user_selections.errors)
  end
end
