# frozen-string-literal: true

# Encapsulates a notional column in the download of a set of statistics, including
# the means for formatting a value for the download file.
class DownloadColumn
  attr_reader :options

  def initialize(options)
    @options = options
  end

  def label # rubocop:disable Metrics/AbcSize
    return options[:label] if options[:label]

    ind_key = options[:ind]&.slug
    stat_key = options[:stat].label_key
    sep = options[:sep] || ' '

    ind_key ? "#{I18n.t(ind_key)}#{sep}#{I18n.t(stat_key)}".html_safe : I18n.t(stat_key)
  end

  def format_value(row)
    if (fn = options[:format])
      fn.call(row)
    elsif (pred = options[:pred])
      simplify_value(row[pred])
    else
      raise "Don't know how to format #{options} of #{row}"
    end
  end

  private

  # Simplify an API value down to a basic term that we can present in a spreadsheet
  def simplify_value(val)
    v = val

    if v.is_a?(Hash)
      v = v['@value'] if v['@value']
      v = v['@id'] if v['@id']
    end

    v = v.first if v.is_a?(Array)

    v
  end
end
