# Raised when a request cannot be served because of a failure below this
# application, such as a malformed response from the data API. Mapped to 500 in
# config/application.rb.
#
# Note this is for failures the controller has already caught and wants to turn
# into an error page. Unhandled exceptions do not need this: they reach the same
# error page through Rails' own `rescue_responses` default of 500.
class UpstreamError < ApplicationRequestError
end
