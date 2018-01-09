# frozen-string-literal: true

require 'test_helper'

# Unit tests on the DownloadPresenter class
class DownloadPresenterTest < ActiveSupport::TestCase
  let(:user_selections) do
    UserSelections.new(ActionController::Parameters.new(
                         location: 'http://landregistry.data.gov.uk/id/region/england',
                         thm: ['property_type']
    ))
  end
  let(:query_results) do
    [
      {
        'ukhpi:averagePriceSA' => [229_454],
        'ukhpi:percentageChangeNewBuild' => [-0.83],
        'ukhpi:housePriceIndexSA' => [113.11],
        'ukhpi:percentageChangeDetached' => [0.93],
        'ukhpi:housePriceIndexFirstTimeBuyer' => [113.95],
        'ukhpi:averagePrice' => [231_049],
        'ukhpi:refPeriodDuration' => [1],
        'ukhpi:housePriceIndexTerraced' => [113.02],
        'ukhpi:percentageAnnualChangeFlatMaisonette' => [6.79],
        'ukhpi:averagePriceSemiDetached' => [213_383],
        'ukhpi:housePriceIndexFlatMaisonette' => [115],
        'ukhpi:averagePriceMortgage' => [237_762],
        'ukhpi:averagePriceNewBuild' => [279_779],
        'ukhpi:percentageAnnualChangeExistingProperty' => [5.55],
        'ukhpi:averagePriceFormerOwnerOccupier' => [261_918],
        'ukhpi:percentageAnnualChangeFirstTimeBuyer' => [5.83],
        'ukhpi:averagePriceDetached' => [349_600],
        'ukhpi:housePriceIndexCash' => [113.28],
        'ukhpi:percentageAnnualChangeSemiDetached' => [5.52],
        'ukhpi:percentageChangeMortgage' => [0.37],
        'ukhpi:percentageChangeCash' => [0.7],
        'ukhpi:refMonth' => {
          '@value' => '2016-11',
          '@type' => 'http://www.w3.org/2001/XMLSchema#gYearMonth'
        },
        'ukhpi:percentageChangeSemiDetached' => [0.34],
        'ukhpi:percentageChangeFormerOwnerOccupier' => [0.51],
        'ukhpi:refRegion' => { '@id' => 'http://landregistry.data.gov.uk/id/region/england' },
        'ukhpi:housePriceIndex' => [113.9],
        'ukhpi:percentageAnnualChangeFormerOwnerOccupier' => [5.68],
        'ukhpi:housePriceIndexExistingProperty' => [113.85],
        'ukhpi:housePriceIndexMortgage' => [114.2],
        'ukhpi:housePriceIndexSemiDetached' => [113.61],
        'ukhpi:averagePriceExistingProperty' => [227_748],
        'ukhpi:percentageAnnualChangeTerraced' => [4.86],
        'ukhpi:percentageAnnualChangeMortgage' => [5.81],
        'ukhpi:refPeriodStart' => [{
          '@value' => '2016-11-01',
          '@type' => 'http://www.w3.org/2001/XMLSchema#date'
        }],
        'ukhpi:housePriceIndexDetached' => [114.45],
        'ukhpi:percentageChange' => [0.47],
        'ukhpi:salesVolume' => [73_754],
        'ukhpi:percentageChangeTerraced' => [0.34],
        'ukhpi:percentageChangeExistingProperty' => [0.57],
        '@id' => 'http://landregistry.data.gov.uk/data/ukhpi/region/england/month/2016-11',
        'ukhpi:averagePriceFirstTimeBuyer' => [194_131],
        'ukhpi:percentageAnnualChangeCash' => [5.6],
        'ukhpi:averagePriceCash' => [217_704],
        'ukhpi:averagePriceTerraced' => [185_497],
        'ukhpi:percentageAnnualChangeDetached' => [6.28],
        'ukhpi:percentageAnnualChange' => [5.74],
        'ukhpi:averagePriceFlatMaisonette' => [218_828],
        'ukhpi:percentageAnnualChangeNewBuild' => [8.39],
        'ukhpi:percentageChangeFlatMaisonette' => [0.33],
        'ukhpi:housePriceIndexNewBuild' => [114.57],
        'ukhpi:percentageChangeFirstTimeBuyer' => [0.42],
        'ukhpi:housePriceIndexFormerOwnerOccupier' => [113.86]
      }
    ]
  end
  let(:query_command) do
    stub(
      user_selections: user_selections,
      results: query_results
    )
  end
  let(:presenter) { DownloadPresenter.new(query_command) }

  let(:user_selections_all) do
    UserSelections.new(ActionController::Parameters.new(
                         location: 'http://landregistry.data.gov.uk/id/region/england'
    ))
  end
  let(:query_command_all) do
    stub(
      user_selections: user_selections_all,
      results: query_results
    )
  end
  let(:presenter_all) { DownloadPresenter.new(query_command_all) }

  describe 'DownloadPresenter' do
    describe '#column_names' do
      it 'should correctly create an array of column names' do
        presenter.column_names.length.must_equal 26
        presenter.column_names.first.must_equal '"Name"'
        presenter.column_names.last.must_equal '"Percentage change (yearly) Flats and maisonettes"'
      end

      it 'should correctly create an array of all column names when no stats are selected' do
        presenter_all.column_names.length.must_be :>=, 61
        presenter.column_names.first.must_equal '"Name"'
        presenter.column_names.last.must_equal '"Percentage change (yearly) Flats and maisonettes"'
      end
    end

    describe '#results' do
      it 'should provide an accessor for the underlying results' do
        presenter.results.length.must_equal 1
      end
    end

    describe '#user_selections' do
      it 'should provide an accessor for the underlying user selections' do
        presenter.user_selections.must_be_same_as user_selections
      end
    end

    describe '#rows' do
      it 'should present the data in rows suitable for rendering' do
        rows = presenter.rows
        row = rows.first

        rows.length.must_equal 1
        row.first.must_equal 'England'
        row.second.must_equal 'http://landregistry.data.gov.uk/id/region/england'
        row[5].must_equal 'monthly'
        row[7].must_equal 231_049
      end
    end
  end
end
