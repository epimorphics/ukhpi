require 'test_helper'

# The print view must render for the shapes of link seen in production, not only
# the `thm[]=...` form the app's own print button produces. The API is stubbed:
# these tests cover the user selections and the presenter, not the query results.
class PrintControllerTest < ActionDispatch::IntegrationTest
  UK = 'http://landregistry.data.gov.uk/id/region/united-kingdom'.freeze

  setup do
    QueryCommand.any_instance.stubs(:perform_query)
    QueryCommand.any_instance.stubs(:results).returns([])
  end

  test 'prints with the default themes when no theme is given' do
    get '/print', params: { 'in[]' => 'avg', from: '2022-01-01', to: '2025-04-30',
                            location: UK, lang: 'en', }

    assert_response :success
    assert_includes @response.body, I18n.t('theme.property_type').downcase
  end

  test 'prints the theme and indicator given as single values' do
    get '/print', params: { in: 'vol', thm: 'buyer_status', from: '1991-01-01',
                            to: '2025-01-01', location: UK, }

    assert_response :success
    assert_includes @response.body, I18n.t('theme.buyer_status').downcase
  end

  test 'prints when every array-valued param is given as a single value' do
    get '/print', params: { in: 'avg', st: 'exi', thm: 'property_status', from: '2021-04-01',
                            to: '2022-04-01',
                            location: 'http://landregistry.data.gov.uk/id/region/lambeth',
                            lang: 'en', }

    assert_response :success
    assert_includes @response.body, I18n.t('theme.property_status').downcase
  end

  test 'prints with no params at all' do
    get '/print'

    assert_response :success
  end

  test 'prints with the default indicators when the indicator is blank' do
    get '/print', params: { in: '' }

    assert_response :success
  end
end
