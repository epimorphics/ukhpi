# frozen_string_literal: true

# Shared code for working with user lanuage choices
module UserLanguage
  def english?
    I18n.locale != :cy
  end

  def welsh?
    I18n.locale == :cy
  end

  def language_slug
    I18n.locale.to_s
  end

  def alternative_language_params
    with('lang', english? ? 'cy' : 'en')
  end
end
