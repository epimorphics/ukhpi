# frozen_string_literal: true

# Entry wrapper for applying generalised grammar rules. Mostly
# this will be used for Welsh grammar actions, such as consonant
# mutations
class Grammar
  def self.apply(options)
    grammar_action = WelshGrammar.apply(options) if I18n.locale == :cy

    grammar_action || GrammarAction.identity_action(options)
  end
end
