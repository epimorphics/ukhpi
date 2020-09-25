# frozen_string_literal: true

# Denotes a consonant mutation in Welsh
class Mutation
  attr_reader :pattern, :replacement_pattern, :new_prefix

  def initialize(pattern, replacement, new_prefix = nil)
    @pattern = pattern
    @replacement_pattern = replacement
    @new_prefix = new_prefix
  end

  def match?(options)
    options[:source]&.match?(prefixed_pattern(options[:prefix]))
  end

  # We assume that `apply` is only invoked if `match?` has
  # already returned `true`
  def apply(options, prefix = nil)
    result = case_preserving_replace(options[:source], prefix)

    GrammarAction.new(options, result, prefix: new_prefix || options[:prefix])
  end

  def case_preserving_replace(source, prefix)
    # post-condition: there will be two capture-groups in `match`: the
    # first for the whole of `pattern`, and the second for the replacement
    # fragment from inside `pattern`
    match = source.match(prefixed_pattern(prefix))

    leading_upper = leading_uppercase_char?(match[1])
    replacement = replacement_pattern.sub('\1', match[2])
    replacement_corrected = replacement_with_correct_case(replacement, leading_upper)

    source.sub(prefixed_pattern(prefix), "#{new_prefix || prefix}#{(new_prefix || prefix) && ' '}#{replacement_corrected}")
  end

  def prefixed_pattern(prefix)
    prefix ? /#{prefix} (#{pattern})/ : /\A(#{pattern})/
  end

  def leading_uppercase_char?(str)
    str.match?(/\A\p{Upper}/)
  end

  def replacement_with_correct_case(replacement, leading_upper)
    replacement_first_char = leading_upper ? replacement.chr.upcase : replacement.chr.downcase
    replacement.sub(/.(.*)/, "#{replacement_first_char}\\1")
  end
end
