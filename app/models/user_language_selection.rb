# frozen_string_literal: true

# This class encapsulates the user input regarding language only.
# It is used on the landing page.
class UserLanguageSelection
  include UserChoices
  include UserLanguage

  DEFAULT_LANGUAGE = 'en'

  USER_PARAMS_MODEL = {
    'lang' => Struct::UserParam.new(DEFAULT_LANGUAGE, false, nil)
  }.freeze

  PERMITTED = USER_PARAMS_MODEL
              .map { |k, v| v.array? ? { k => [] } : k }
              .freeze

  def initialize(params)
    @params = params[:__safe_params] || params.permit(*PERMITTED)
  end

  def user_params_model
    USER_PARAMS_MODEL
  end
end
