require 'test_helper'

# The API is stubbed: these tests cover the user selections, not the query results.
class BrowseControllerTest < ActionDispatch::IntegrationTest
  setup do
    QueryCommand.any_instance.stubs(:perform_query)
    QueryCommand.any_instance.stubs(:results).returns([])
  end

  # Older versions of the app put the legacy `volume` theme in their own show/hide
  # theme links, so those links must still work (#687). This one is from prod logs.
  test 'browses from a link with the legacy volume theme' do
    get '/browse?lang=en&st%5B%5D=det&st%5B%5D=fla&st%5B%5D=mor&thm%5B%5D=buyer_status&thm%5B%5D=volume'

    assert_response :success
  end
end
