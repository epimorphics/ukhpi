# frozen-string-literal: true

# Format values in a consistent way
class ValueFormatter
  def self.format(value, options)
    formatted = (empty?(value) ? nil_formatter : formatter(options)).call(value)
    if options.key?(:template)
      Kernel.format(options[:template], formatted: formatted)
    else
      formatted
    end.html_safe
  end

  def self.empty?(value)
    value.nil? || (value.respond_to?(:empty?) && value.empty?)
  end

  def self.formatter(options)
    return formatter_by_slug(options[:slug]) if options.key?(:slug)

    default_formatter
  end

  def self.formatter_by_slug(slug)
    case slug.to_s.downcase
    when /average/ then currency_formatter
    when /percent/ then percent_formatter
    else index_formatter
    end
  end

  def self.nil_formatter
    ->(_val) { '' }
  end

  def self.default_formatter
    ->(val) { val.to_s }
  end

  def self.currency_formatter
    ->(val) { number_to_currency(val.to_i, locale: :'en-GB', precision: 0) }
  end

  def self.percent_formatter
    ->(val) { Kernel.format('%.1f%%', val) }
  end

  def self.index_formatter
    ->(val) { Kernel.format('%.1f', val) }
  end

  def self.number_to_currency(val, options)
    Class.new do
      include ActionView::Helpers::NumberHelper
    end.new.number_to_currency(val, options)
  end

  def self.month_year(date)
    I18n.l(Date.strptime(date, '%Y-%m'), format: '%B %Y')
  end
end
