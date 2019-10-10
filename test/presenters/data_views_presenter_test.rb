# frozen-string-literal: true

require 'test_helper'

# Unit tests on the DataViewsPresenter class
class DataViewsPresenterTest < ActiveSupport::TestCase
  let(:user_selections) do
    UserSelections.new(ActionController::Parameters.new)
  end
  let(:query_result) { nil }
  let(:presenter) { DataViewsPresenter.new(user_selections, query_result) }

  describe 'DataViewPresenter' do
    describe '#data_views' do
      it 'should create the right number of views' do
        _(presenter.data_views).must_be_kind_of(Array)
        _(presenter.data_views.length).must_be :>=, 17
        presenter.data_views.each { |view| _(view).must_be_kind_of DataView }
      end
    end
  end
end
