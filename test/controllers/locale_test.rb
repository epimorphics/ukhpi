require 'test_helper'

# The `lang` param picks the page's language. A value we don't support, including
# a blank one, must be ignored rather than raise I18n::InvalidLocale (#678), and
# the language then comes from Accept-Language as if `lang` were absent. The docs
# page is used because it renders without calling the API.
class LocaleTest < ActionDispatch::IntegrationTest
  # The header links to the language that is not currently shown
  WELSH_PAGE = %r{<a [^>]*>English</a>}
  ENGLISH_PAGE = %r{<a [^>]*>Cymraeg</a>}

  teardown do
    I18n.locale = I18n.default_locale
  end

  test 'a supported lang sets the language' do
    get '/doc', params: { lang: 'cy' }

    assert_response :success
    assert_match WELSH_PAGE, @response.body
  end

  [ 'en\\', 'cy\\', 'xx', '' ].each do |lang|
    test "an unsupported lang #{lang.inspect} is ignored" do
      get '/doc', params: { lang: lang }

      assert_response :success
      assert_match ENGLISH_PAGE, @response.body
    end
  end

  test 'an unsupported lang falls back to Accept-Language' do
    get '/doc', params: { lang: 'cy\\' }, headers: { 'Accept-Language' => 'cy' }

    assert_response :success
    assert_match WELSH_PAGE, @response.body
  end
end
