# frozen_string_literal: true

# Denotes a consonant mutation in Welsh
class Mutation
  attr_reader :pattern, :replacement

  def initialize(pattern, replacement)
    @pattern = pattern
    @replacement = replacement
  end

  def match?(options)
    options[:source]&.match?(pattern)
  end

  def apply(options)
    GrammarAction.new(
      options,
      options[:source]&.sub(pattern, replacement)
    )
  end
end
