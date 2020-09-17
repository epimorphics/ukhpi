# frozen_string_literal: true

Mutation = Struct.new(:pattern, :replacement)

MUTATIONS = {
  'o' =>
    [
      Mutation.new(/Mawrth/, 'Fawrth'),
      Mutation.new(/Mai/, 'Fai'),
      Mutation.new(/Mehefin/, 'Fehefin'),
      Mutation.new(/Gorffennaf/, 'Orffennaf'),
      Mutation.new(/Medi/, 'Fedi'),
      Mutation.new(/Tachwedd/, 'Dachwedd'),
      Mutation.new(/Rhagfyr/, 'Ragfyr')
    ]
}.freeze

# Assistance with formulating correct Welsh grammar
class WelshGrammar
  def self.mutate(options)
    result = nil

    if I18n.locale == 'cy'
      result = mutate_prefix(options[:assuming_prefix], options) if options[:assuming_prefix]
    end

    result || GrammarAction.identity_action(options)
  end

  private

  def mutate_prefix(prefix, options)
    return nil unless (mutations = MUTATIONS[prefix])

    mutations
      .find { |mutation| mutation.match?(options) }
      &.apply(options)
  end
end
