# Module that encapsulates the concern of formatting values in a suitable way
# for rendering as part of a download
module DownloadFormatter
  FIXED_COLUMNS = [
    DownloadColumn.new(
      label: 'Name',
      # Fall back to the URI for a region the API knows but our location table doesn't
      format: lambda do |row|
        uri = row['ukhpi:refRegion']['@id']
        Locations.lookup_location(uri)&.label || uri
      end
    ),
    DownloadColumn.new(
      label: 'URI',
      pred: 'ukhpi:refRegion'
    ),
    DownloadColumn.new(
      label: 'Region GSS code',
      format: ->(row) { Locations.lookup_location(row['ukhpi:refRegion']['@id'])&.gss }
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
    ),
  ].freeze

  SUPPLEMENTARY_COLUMNS = [
    DownloadColumn.new(
      label: 'Pivotable date',
      format: ->(row) { "#{row['ukhpi:refMonth']['@value']}-01" }
    ),
  ].freeze
end
