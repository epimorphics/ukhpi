# frozen_string_literal: true

require 'test_helper'

# Unit tests on Welsh grammar support
class WelshGrammarTest < ActiveSupport::TestCase
  describe 'WelshGrammar' do
    teardown do
      I18n.locale = :en
    end

    describe 'mutations' do
      before do
        I18n.locale = :en
      end

      it 'make no changes if language is not Welsh' do
        _(
          WelshGrammar
            .mutate(source: 'Ionawr', assuming_prefix: 'o')
            .result
        ).must_equal('Ionawr')
      end

      it 'should mutate months that are prefix by "O" if necessary' do
        I18n.locale = :cy

        _(
          WelshGrammar
            .mutate(source: 'Ionawr', assuming_prefix: 'o')
            .result
        ).must_equal('Ionawr')

        _(
          WelshGrammar
            .mutate(source: 'Mai', assuming_prefix: 'o')
            .result
        ).must_equal('Fai')
      end
    end
  end
end
