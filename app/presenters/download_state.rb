# frozen_string_literal: true

# Presenter for download information
class DownloadState < Presenter
  STANDARD_COLUMNS = [
    { label: 'Name' },
    { label: 'URI' },
    { label: 'Region_GSS_code' },
    { label: 'Period' },
    { label: 'SalesVolume' },
    { label: 'ReportingPeriod' }
  ].freeze

  def column_names
    (STANDARD_COLUMNS.map { |c| c[:label] }) + annotate_columns(visible_aspects, quarterly_results?)
  end

  def rows
    query_results.map { |r| as_row(r) }
  end

  # rubocop:disable Metrics/AbcSize
  def as_row(r)
    uri = r['ukhpi:refRegion']['@id']
    region = Regions.lookup_region(uri)
    date = r['ukhpi:refMonth']['@value']
    region_label = "\'#{region.label}\'"
    volume = (sv = r['ukhpi:salesVolume']) ? sv.first : ''
    report_period = result_period_duration(r) == 3 ? 'quarterly' : 'monthly'

    [region_label, uri, region.gss, date, volume, report_period] +
      visible_aspects.map { |a| r["ukhpi:#{a}"] }
  end

  def as_filename
    prefs
      .summary
      .gsub(/[ [[:punct:]]]/, '-')
      .gsub('--', '-')
      .downcase
      .strip
  end

  def quarterly_results?
    (sample = sample_result) && result_period_duration(sample) == 3
  end

  def query_results
    cmd.cmd.results
  end

  def sample_result
    !query_results.empty? && query_results.first
  end

  def result_period_duration(result)
    result['ukhpi:refPeriodDuration'].first
  end

  def annotate_columns(aspects, quarterly)
    annotation = quarterly ? 'Quarterly' : 'Monthly'

    aspects.map do |aspect|
      aspect.start_with?('percentageChange') ? "#{aspect}#{annotation}" : aspect
    end
  end
end
