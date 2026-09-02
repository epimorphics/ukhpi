# Raised when a request cannot be fulfilled, either because the user's
# selections were invalid (400) or because building a view from them failed
# unexpectedly (500). Carries the user_selections so the error page can show
# validation messages and preserve the user's in-progress form state.
class ApplicationRequestError < StandardError
  attr_reader :user_selections, :status

  def initialize(user_selections, status, message = nil)
    super(message)
    @user_selections = user_selections
    @status = status
  end
end
