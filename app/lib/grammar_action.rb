# frozen_string_literal: true

# Encapsulates a change resulting from applying grammar rules
class GrammarAction
  attr_reader :options, :result, :prefix, :suffix

  def initialize(options, result, prefix: nil, suffix: nil)
    @options = options
    @result = result
    @prefix = prefix
    @suffix = suffix
  end

  def self.identity_action(options)
    GrammarAction.new(
      options,
      options[:source],
      prefix: options[:prefix] || options[:assuming_prefix]
    )
  end
end
