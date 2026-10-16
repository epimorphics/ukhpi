# Raised when the data API rejects a query with a 4xx status. That means this
# application built a bad query, so unlike an API outage it is our fault: it is
# left out of `rescue_responses`, so it becomes a 500, counts as an internal
# error and is reported to Sentry.
class ApiQueryError < StandardError
end
