# frozen_string_literal: true

require 'test_helper'

class WelshGrammarTest < ActiveSupport::TestCase
  describe 'WelshGrammar' do
    describe 'mutations' do
      it 'should mutate months that are prefix by "O" if necessary' do
        _(
          WelshGrammar
            .mutate(source: 'Ionawr', assuming_prefix: 'o')
            .result
        ).must_equal('Ionawr')
      end
    end
  end
end
