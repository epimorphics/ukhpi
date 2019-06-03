# frozen-string-literal: true

require 'test_helper'

# Unit tests on the CompareLocationsPresenter class
# rubocop:disable Metrics/LineLength
class CompareLocationsPresenterTest < ActiveSupport::TestCase
  let(:user_selections) do
    UserCompareSelections.new(ActionController::Parameters.new(
                                location: %w[K02000001 E10000024],
                                st: 'all',
                                in: 'hpi'
                              ))
  end
  let(:query_results) do
    { 'United Kingdom' =>
      [{ 'ukhpi:averagePriceSA' => [227_147],
         'ukhpi:percentageChangeNewBuild' => [],
         'ukhpi:housePriceIndexSA' => [119.13],
         'ukhpi:salesVolumeMortgage' => [],
         'ukhpi:percentageChangeDetached' => [1.97],
         'ukhpi:housePriceIndexFirstTimeBuyer' => [],
         'ukhpi:averagePrice' => [231_422],
         'ukhpi:refPeriodDuration' => [1],
         'ukhpi:housePriceIndexTerraced' => [121.22],
         'ukhpi:percentageAnnualChangeFlatMaisonette' => [0.65],
         'ukhpi:averagePriceSemiDetached' => [216_785],
         'ukhpi:housePriceIndexFlatMaisonette' => [120.64],
         'ukhpi:averagePriceMortgage' => [],
         'ukhpi:averagePriceNewBuild' => [],
         'ukhpi:percentageAnnualChangeExistingProperty' => [],
         'ukhpi:averagePriceFormerOwnerOccupier' => [],
         'ukhpi:percentageAnnualChangeFirstTimeBuyer' => [],
         'ukhpi:averagePriceDetached' => [352_138],
         'ukhpi:housePriceIndexCash' => [],
         'ukhpi:percentageAnnualChangeSemiDetached' => [3.26],
         'ukhpi:percentageChangeMortgage' => [],
         'ukhpi:percentageChangeCash' => [],
         'ukhpi:refMonth' =>
         { '@value' => '2018-07',
           '@type' => 'http://www.w3.org/2001/XMLSchema#gYearMonth' },
         'ukhpi:percentageChangeSemiDetached' => [0.05],
         'ukhpi:percentageChangeFormerOwnerOccupier' => [],
         'ukhpi:refRegion' =>
         { '@id' => 'http://landregistry.data.gov.uk/id/region/united-kingdom' },
         'ukhpi:housePriceIndex' => [121.38],
         'ukhpi:percentageAnnualChangeFormerOwnerOccupier' => [],
         'ukhpi:housePriceIndexExistingProperty' => [],
         'ukhpi:housePriceIndexMortgage' => [],
         'ukhpi:housePriceIndexSemiDetached' => [121.26],
         'ukhpi:averagePriceExistingProperty' => [],
         'ukhpi:percentageAnnualChangeTerraced' => [3.36],
         'ukhpi:percentageAnnualChangeMortgage' => [],
         'ukhpi:refPeriodStart' =>
         [{ '@value' => '2018-07-01',
            '@type' => 'http://www.w3.org/2001/XMLSchema#date' }],
         'ukhpi:housePriceIndexDetached' => [122.38],
         'ukhpi:percentageChange' => [1.16],
         'ukhpi:salesVolume' => [],
         'ukhpi:percentageChangeTerraced' => [1.23],
         'ukhpi:percentageChangeExistingProperty' => [],
         '@id' =>
         'http://landregistry.data.gov.uk/data/ukhpi/region/united-kingdom/month/2018-07',
         'ukhpi:averagePriceFirstTimeBuyer' => [],
         'ukhpi:percentageAnnualChangeCash' => [],
         'ukhpi:averagePriceCash' => [],
         'ukhpi:averagePriceTerraced' => [187_247],
         'ukhpi:percentageAnnualChangeDetached' => [4.62],
         'ukhpi:percentageAnnualChange' => [3.06],
         'ukhpi:salesVolumeCash' => [],
         'ukhpi:averagePriceFlatMaisonette' => [207_639],
         'ukhpi:salesVolumeNewBuild' => [],
         'ukhpi:salesVolumeExistingProperty' => [],
         'ukhpi:percentageAnnualChangeNewBuild' => [],
         'ukhpi:percentageChangeFlatMaisonette' => [1.58],
         'ukhpi:housePriceIndexNewBuild' => [],
         'ukhpi:percentageChangeFirstTimeBuyer' => [],
         'ukhpi:housePriceIndexFormerOwnerOccupier' => [] }],
      'Nottinghamshire' =>
      [{ 'ukhpi:averagePriceSA' => [],
         'ukhpi:percentageChangeNewBuild' => [],
         'ukhpi:housePriceIndexSA' => [],
         'ukhpi:salesVolumeMortgage' => [],
         'ukhpi:percentageChangeDetached' => [0.84],
         'ukhpi:housePriceIndexFirstTimeBuyer' => [120.26],
         'ukhpi:averagePrice' => [173_969],
         'ukhpi:refPeriodDuration' => [1],
         'ukhpi:housePriceIndexTerraced' => [119.02],
         'ukhpi:percentageAnnualChangeFlatMaisonette' => [2.03],
         'ukhpi:averagePriceSemiDetached' => [155_619],
         'ukhpi:housePriceIndexFlatMaisonette' => [119.25],
         'ukhpi:averagePriceMortgage' => [176_576],
         'ukhpi:averagePriceNewBuild' => [],
         'ukhpi:percentageAnnualChangeExistingProperty' => [],
         'ukhpi:averagePriceFormerOwnerOccupier' => [195_952],
         'ukhpi:percentageAnnualChangeFirstTimeBuyer' => [4.71],
         'ukhpi:averagePriceDetached' => [251_794],
         'ukhpi:housePriceIndexCash' => [120.2],
         'ukhpi:percentageAnnualChangeSemiDetached' => [5.13],
         'ukhpi:percentageChangeMortgage' => [0.54],
         'ukhpi:percentageChangeCash' => [0.84],
         'ukhpi:refMonth' =>
         { '@value' => '2018-07',
           '@type' => 'http://www.w3.org/2001/XMLSchema#gYearMonth' },
         'ukhpi:percentageChangeSemiDetached' => [0.5],
         'ukhpi:percentageChangeFormerOwnerOccupier' => [0.7],
         'ukhpi:refRegion' =>
         { '@id' => 'http://landregistry.data.gov.uk/id/region/nottinghamshire' },
         'ukhpi:housePriceIndex' => [120.5],
         'ukhpi:percentageAnnualChangeFormerOwnerOccupier' => [5.22],
         'ukhpi:housePriceIndexExistingProperty' => [],
         'ukhpi:housePriceIndexMortgage' => [120.64],
         'ukhpi:housePriceIndexSemiDetached' => [120.72],
         'ukhpi:averagePriceExistingProperty' => [],
         'ukhpi:percentageAnnualChangeTerraced' => [4.61],
         'ukhpi:percentageAnnualChangeMortgage' => [5.03],
         'ukhpi:refPeriodStart' =>
         [{ '@value' => '2018-07-01',
            '@type' => 'http://www.w3.org/2001/XMLSchema#date' }],
         'ukhpi:housePriceIndexDetached' => [121.34],
         'ukhpi:percentageChange' => [0.63],
         'ukhpi:salesVolume' => [],
         'ukhpi:percentageChangeTerraced' => [0.55],
         'ukhpi:percentageChangeExistingProperty' => [],
         '@id' =>
         'http://landregistry.data.gov.uk/data/ukhpi/region/nottinghamshire/month/2018-07',
         'ukhpi:averagePriceFirstTimeBuyer' => [145_090],
         'ukhpi:percentageAnnualChangeCash' => [4.91],
         'ukhpi:averagePriceCash' => [168_585],
         'ukhpi:averagePriceTerraced' => [122_620],
         'ukhpi:percentageAnnualChangeDetached' => [5.52],
         'ukhpi:percentageAnnualChange' => [4.99],
         'ukhpi:salesVolumeCash' => [],
         'ukhpi:averagePriceFlatMaisonette' => [106_457],
         'ukhpi:salesVolumeNewBuild' => [],
         'ukhpi:salesVolumeExistingProperty' => [],
         'ukhpi:percentageAnnualChangeNewBuild' => [],
         'ukhpi:percentageChangeFlatMaisonette' => [0.25],
         'ukhpi:housePriceIndexNewBuild' => [],
         'ukhpi:percentageChangeFirstTimeBuyer' => [0.54],
         'ukhpi:housePriceIndexFormerOwnerOccupier' => [120.61] }] }
  end

  let(:presenter) { CompareLocationsPresenter.new(user_selections, query_results) }

  describe 'CompareLocationsPresenter' do
    describe '#headline_summary' do
      it 'should correctly generate a summary headline' do
        presenter
          .headline_summary
          .must_match %r{<strong>House price index</strong> for <strong>all property types</strong>, ... \d{4} to ... \d{4}}
      end
    end

    describe '#locations_summary' do
      it 'should correctly summarise the locations' do
        presenter
          .locations_summary
          .must_equal 'United Kingdom and Nottinghamshire'
      end
    end

    describe '#without_location' do
      it 'should present the user selections without the location' do
        mock_location = mock('location', gss: 'K02000001')
        selections = presenter.without_location(mock_location)
        selections['location'].length.must_equal 1
        selections['location'].must_include 'E10000024'
      end
    end

    describe '#with_statistic' do
      it 'should present the user selection with a statistic added' do
        mock_statistic = mock('statistic', slug: 'ftb')
        mock_indicator = mock('indicator', slug: 'pac')
        selections = presenter.with_statistic(mock_statistic, mock_indicator)

        selections['st'].must_equal 'ftb'
        selections['in'].must_equal 'pac'
      end
    end

    describe '#query_results_rows' do
      it 'convert the results to an array of rows' do
        rows = presenter.query_results_rows
        rows.length.must_equal 1
        rows.first.first.must_equal 'Jul 2018'
        rows.first[1].must_be_close_to 121.38
      end
    end

    describe '#format' do
      it 'should format a value' do
        presenter.format(1234.56).must_equal "<div class='u-text-right'>1234.6</div>"
      end
    end

    describe '#indicator' do
      it 'should look up the indicator being used' do
        presenter.indicator.label_key.must_equal 'house_price_index'
      end
    end
  end
end
# rubocop:enable Metrics/LineLength
