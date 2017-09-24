# frozen-string-literal: true

require 'test_helper'

# Unit tests on the UserSelectionsPresenter class
class UserSelectionsPresenterTest < ActiveSupport::TestCase
  let :selections do
    UserSelections.new(
      ActionController::Parameters.new(
        'region' => 'http://landregistry.data.gov.uk/id/region/wales',
        'from' => Date.new(2017, 2, 3),
        'to' => Date.new(2017, 8, 31),
        'in' => %w[averagePrice housePriceIndex]
      )
    )
  end

  let :presenter { UserSelectionsPresenter.new(selections) }

  describe '#UserSelectionsPresenter' do
    describe '#as_url_search_string' do
      it 'should translate the selections to a well-formed search string' do
        presenter.as_url_search_string.must_equal 'from=2017-02-03&'\
          'in%5B%5D=averagePrice&in%5B%5D=housePriceIndex&'\
          'region=http%3A%2F%2Flandregistry.data.gov.uk%2Fid%2Fregion%2Fwales&'\
          'to=2017-08-31'
      end
    end

    describe '#as_title' do
      it 'should translate the selections into a readable title' do
        presenter.as_title.must_equal 'Wales from February 2017 to August 2017'
      end
    end
  end
end
