# frozen_string_literal: true

# Module that encapsulates the concern of formatting values in a suitable way
# for rendering as part of a download
module DownloadFormatter
  FIXED_COLUMNS = [
    DownloadColumn.new(
      label: 'Name',
      format: ->(row) { Locations.lookup_location(row['ukhpi:refRegion']['@id']).label }
    ),
    DownloadColumn.new(
      label: 'URI',
      pred: 'ukhpi:refRegion'
    ),
    DownloadColumn.new(
      label: 'Region GSS code',
      format: ->(row) { Locations.lookup_location(row['ukhpi:refRegion']['@id']).gss }
    ),
    DownloadColumn.new(
      label: 'Period',
      pred: 'ukhpi:refMonth'
    ),
    DownloadColumn.new(
      label: 'Sales volume',
      pred: 'ukhpi:salesVolume'
    ),
    DownloadColumn.new(
      label: 'Reporting period',
      format: ->(row) { row['ukhpi:refPeriodDuration'].first == 3 ? 'quarterly' : 'monthly' }
    )
  ].freeze

  SUPPLEMENTARY_COLUMNS = [
    DownloadColumn.new(
      label: 'Pivotable date',
      format: ->(row) { "#{row['ukhpi:refMonth']['@value']}-01" }
    )
  ].freeze
end
