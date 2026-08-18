require 'test_helper'

# Regression test for the wildcard route in config/routes.rb, which points
# unmatched routes at application#render_404. That action was previously
# removed from ApplicationController during an error-handling refactor while
# the route reference was left in place, so unmatched routes were raising
# AbstractController::ActionNotFound and rendering as unhandled 500s instead
# of clean 404s.
class UnmatchedRouteTest < ActionDispatch::IntegrationTest
  test 'renders a 404 page for an unmatched route' do
    get '/this-route-does-not-exist'

    assert_response :not_found
    assert_includes @response.body, 'Page not found'
  end
end
