# frozen-string-literal: true

# Module that encapsulates the concern of formatting values in a suitable way
# for rendering as part of a download
module DownloadFormatter
  def self.region_uri(row)
    row['ukhpi:refRegion']['@id']
  end

  def self.region(row)
    Regions.lookup_region(region_uri(row))
  end

  def self.region_gss(row)
    region(row).gss
  end

  def self.ref_month(row)
    row['ukhpi:refMonth']['@value']
  end

  def self.sales_volume(row)
    row['ukhpi:salesVolume']&.first
  end

  def self.reporting_period(row)
    row['ukhpi:refPeriodDuration'].first
  end

  def self.reporting_period_label(row)
    reporting_period(row) == 3 ? 'quarterly' : 'monthly'
  end

  def self.region_name(row)
    I18n.t(region(row).label_key)
  end

  FIXED_COLUMNS = [
    {
      label: 'Name',
      format: method(:region_name)
    },
    {
      label: 'URI',
      format: method(:region_uri)
    },
    {
      label: 'Region_GSS_code',
      format: method(:region_gss)
    },
    {
      label: 'Period',
      format: method(:ref_month)
    },
    {
      label: 'SalesVolume',
      format: method(:sales_volume)
    },
    {
      label: 'ReportingPeriod',
      format: method(:reporting_period_label)
    }
  ].freeze
end
