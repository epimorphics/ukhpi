# frozen-string-literal: true

# Module that encapsulates the concern of formatting values in a suitable way
# for rendering as part of a download
module DownloadFormatter
  FIXED_COLUMNS = [
    {
      label: 'Name',
      pred: 'static:regionName'
    },
    {
      label: 'URI',
      pred: 'static:regionURI'
    },
    {
      label: 'Region GSS code',
      pred: 'static:regionGSS'
    },
    {
      label: 'Period',
      pred: 'ukhpi:refMonth'
    },
    {
      label: 'Sales volume',
      pred: 'ukhpi:salesVolume'
    },
    {
      label: 'Reporting period',
      pred: 'static:reportingPeriod'
    }
  ].freeze

  def location_uri(row)
    row['ukhpi:refRegion']['@id']
  end

  def location(row)
    Locations.lookup_location(location_uri(row))
  end

  def location_name(row)
    location(row).label
  end

  def location_gss(row)
    location(row).gss
  end

  def ref_month(row)
    row['ukhpi:refMonth']['@value']
  end

  def sales_volume(row)
    row['ukhpi:salesVolume']&.first
  end

  def reporting_period(row)
    row['ukhpi:refPeriodDuration'].first
  end

  def reporting_period_label(row)
    reporting_period(row) == 3 ? 'quarterly' : 'monthly'
  end
end
