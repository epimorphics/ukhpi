require 'test_helper'

# Downloads must work for any HTTP client, including scripts and bots that send
# no User-Agent header. The API is stubbed: these tests cover the response
# headers, not the query results.
class DownloadControllerTest < ActionDispatch::IntegrationTest
  UK = 'http://landregistry.data.gov.uk/id/region/united-kingdom'.freeze
  NO_USER_AGENT = { 'User-Agent' => nil }.freeze

  setup do
    QueryCommand.any_instance.stubs(:perform_query)
    QueryCommand.any_instance.stubs(:results).returns([])
  end

  test 'downloads CSV for a single location with no User-Agent' do
    get '/download/new.csv', params: { location: UK, 'thm[]' => 'property_type',
                                       from: '1966-01-01', to: '2026-01-01', },
                             headers: NO_USER_AGENT

    assert_nil request.user_agent
    assert_response :success
    assert_equal 'text/csv', @response.media_type
    assert_match(/\Aattachment; filename="ukhpi-.+\.csv"\z/, @response.headers['Content-Disposition'])
  end

  test 'downloads JSON for a single location with no User-Agent' do
    get '/download/new.json', params: { location: UK, 'in[]' => 'hpi' },
                              headers: NO_USER_AGENT

    assert_nil request.user_agent
    assert_response :success
    assert_equal 'application/json', @response.media_type
    assert_match(/\Aattachment; filename="ukhpi-.+\.json"\z/, @response.headers['Content-Disposition'])
  end

  test 'downloads CSV for multiple locations with no User-Agent' do
    get '/download/new.csv', params: { 'location[]' => %w[W92000004 E92000001 N92000002],
                                       'st[]' => 'all', 'in[]' => 'hpi',
                                       from: '2025-02-13', to: '2026-02-13', },
                             headers: NO_USER_AGENT

    assert_nil request.user_agent
    assert_response :success
    assert_equal 'text/csv', @response.media_type
    assert_match(/\Aattachment; filename="ukhpi-comparison-.+\.csv"\z/,
                 @response.headers['Content-Disposition'])
  end

  test 'downloads CSV with the real MIME type for an Internet Explorer User-Agent' do
    get '/download/new.csv', params: { location: UK, 'in[]' => 'hpi' },
                             headers: { 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 8.0)' }

    assert_response :success
    assert_equal 'text/csv', @response.media_type
  end
end
