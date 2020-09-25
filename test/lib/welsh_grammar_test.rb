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
            .apply(source: 'Ionawr', assuming_prefix: 'o')
            .result
        ).must_equal('Ionawr')
      end

      it 'should mutate months that are prefix by "o" if necessary' do
        I18n.locale = :cy

        result = WelshGrammar.mutate(source: 'Ionawr', assuming_prefix: 'o')
        _(result.result).must_equal('Ionawr')

        result = WelshGrammar.mutate(source: 'Mai', assuming_prefix: 'o')
        _(result.result).must_equal('Fai')
      end

      it 'should mutate a placenmame with an assumed prefix' do
        I18n.locale = :cy

        result = WelshGrammar.mutate(source: 'Gwynedd', assuming_prefix: 'yn')
        _(result.result).must_equal('Ngwynedd')
        _(result.prefix).must_equal('yng')
      end

      it 'should mutate if the prefix is "yn"' do
        I18n.locale = :cy

        result = WelshGrammar.mutate(source: 'yn Bxxyy', prefix: 'yn')
        _(result.result).must_equal('ym Mxxyy')

        result = WelshGrammar.mutate(source: 'some text yn Bxxyy', prefix: 'yn')
        _(result.result).must_equal('some text ym Mxxyy')

        result = WelshGrammar.mutate(source: 'yn Cxxyy', prefix: 'yn')
        _(result.result).must_equal('yng Nghxxyy')

        result = WelshGrammar.mutate(source: 'some text yn Cxxyy', prefix: 'yn')
        _(result.result).must_equal('some text yng Nghxxyy')
      end

      it 'should mutate if the prefix is "o"' do
        I18n.locale = :cy

        result = WelshGrammar.mutate(source: 'o Mxxyy', prefix: 'o')
        _(result.result).must_equal('o Fxxyy')
        result = WelshGrammar.mutate(source: 'some text o Mxxyy', prefix: 'o')
        _(result.result).must_equal('some text o Fxxyy')
        result = WelshGrammar.mutate(source: 'some text o Gxxyy', prefix: 'o')
        _(result.result).must_equal('some text o Xxyy')
      end

      it 'should mutate if the prefix is "i"' do
        I18n.locale = :cy

        result = WelshGrammar.mutate(source: 'i Rhxxyy', prefix: 'i')
        _(result.result).must_equal('i Rxxyy')
        result = WelshGrammar.mutate(source: 'some text i Mxxyy', prefix: 'i')
        _(result.result).must_equal('some text i Fxxyy')
        result = WelshGrammar.mutate(source: 'some text i llxxyy', prefix: 'i')
        _(result.result).must_equal('some text i xxyy')
      end

      it 'should preserve the case of the mutated value' do
        I18n.locale = :cy

        result = WelshGrammar.mutate(source: 'yn Dxxyy', prefix: 'yn')
        _(result.result).must_equal('yn Nxxyy')
        result = WelshGrammar.mutate(source: 'yn dxxyy', prefix: 'yn')
        _(result.result).must_equal('yn nxxyy')
      end
    end
  end
end
