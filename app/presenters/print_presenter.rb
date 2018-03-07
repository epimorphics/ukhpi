# frozen-string-literal: true

# A presenter for the printable view, based on the download view presenter
class PrintPresenter < DownloadPresenter
  PRINT_COLUMNS = [
    DownloadColumn.new(
      label: 'Name',
      format: ->(row) { Locations.lookup_location(row['ukhpi:refRegion']['@id']).label }
    ),
    DownloadColumn.new(
      label: 'Period',
      format: ->(row) { Date.parse("#{row['ukhpi:refMonth']['@value']}-01").strftime('%B %Y') }
    ),
    DownloadColumn.new(
      label: 'Reporting period',
      format: ->(row) { row['ukhpi:refPeriodDuration'].first == 3 ? 'quarterly' : 'monthly' }
    ),
    DownloadColumn.new(
      label: 'Sales volume',
      pred: 'ukhpi:salesVolume'
    )
  ].freeze

  def locations
    @locations ||=
      Array(user_selections.selected_location)
      .map { |uri| Locations.lookup_location(uri) }
  end

  def locations_summary # rubocop:disable Metrics/AbcSize
    if locations.one?
      locations.first.label
    elsif locations.length == 2
      "#{locations.first.label} and #{locations[1].label}"
    else
      "#{locations.length} locations"
    end
  end

  def indicators
    user_selections
      .selected_indicators
      .map { |slug| ukhpi.indicator(slug) }
  end

  def indicator_summary
    indicators
      .map(&:label)
      .join(' and ')
  end

  def statistics
    user_selections
      .selected_statistics
      .map { |slug| ukhpi.statistic(slug) }
  end

  def statistic_summary
    statistics
      .map(&:label)
      .join(' and ')
  end

  def themes
    user_selections
      .selected_themes
      .map { |slug| ukhpi.theme(slug) }
  end

  def theme_summary
    themes
      .map(&:label)
      .join(' and ')
  end

  def dates
    @dates ||=
      [
        user_selections.from_date,
        user_selections.to_date
      ]
  end

  def dates_summary
    dates
      .map { |date| date.strftime('%B %Y') }
      .join(' &ndash; ')
      .html_safe
  end

  def column_names
    columns.map(&:label)
  end

  private

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end

  def columns
    @columns ||= PRINT_COLUMNS + user_selection_columns
  end

  def user_selection_columns
    selected_statistics.map(&method(:statistic_indicator_columns)).flatten
  end
end
