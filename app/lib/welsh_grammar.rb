# frozen_string_literal: true

MUTATIONS = {
  'yn' =>
    [
      Mutation.new(/b(.*)/i, 'm\1', 'ym'),
      Mutation.new(/p(.*)/i, 'mh\1', 'ym'),
      Mutation.new(/g(.*)/i, 'ng\1', 'yng'),
      Mutation.new(/t(.*)/i, 'nh\1'),
      Mutation.new(/c(.*)/i, 'ngh\1', 'yng'),
      Mutation.new(/d(.*)/i, 'n\1'),
      Mutation.new(/m(.*)/i, 'm\1', 'ym')
    ],
  'o' =>
    [
      Mutation.new(/m(.*)/i, 'f\1'),
      Mutation.new(/g(.*)/i, '\1'),
      Mutation.new(/t(.*)/i, 'd\1'),
      Mutation.new(/rh(.*)/i, 'r\1'),
      Mutation.new(/b(.*)/i, 'f\1'),
      Mutation.new(/c(.*)/i, 'g\1'),
      Mutation.new(/d(.*)/i, 'dd\1'),
      Mutation.new(/ll(.*)/i, '\1'),
      Mutation.new(/p(.*)/i, 'b\1')
    ],
  'i' =>
    [
      Mutation.new(/m(.*)/i, 'f\1'),
      Mutation.new(/g(.*)/i, '\1'),
      Mutation.new(/t(.*)/i, 'd\1'),
      Mutation.new(/rh(.*)/i, 'r\1'),
      Mutation.new(/b(.*)/i, 'f\1'),
      Mutation.new(/c(.*)/i, 'g\1'),
      Mutation.new(/d(.*)/i, 'dd\1'),
      Mutation.new(/ll(.*)/i, '\1'),
      Mutation.new(/p(.*)/i, 'b\1')
    ]
}.freeze

# Assistance with formulating correct Welsh grammar
class WelshGrammar
  def self.apply(options)
    mutate(options)
  end

  def self.mutate(options)
    result = apply_mutations(options) if I18n.locale == :cy

    result || GrammarAction.identity_action(options)
  end

  def self.apply_mutations(options)
    if options[:assuming_prefix]
      mutate_prefix(options[:assuming_prefix], options)
    elsif options[:prefix]
      mutate_prefix(options[:prefix], options)
      # result.update_result(/#{options[:prefix]} /, result.prefix)
    end
  end

  def self.mutate_prefix(prefix, options)
    return nil unless (mutations = MUTATIONS[prefix])

    mutations
      .find { |mutation| mutation.match?(options) }
      &.apply(options, options[:prefix])
  end
end
