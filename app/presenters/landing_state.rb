# frozen_string_literal: true

# Presenter for the state needed to drive the landing page
class LandingState
  attr_reader :latest

  def initialize(lvc = LatestValuesCommand)
    @latest = lvc.new
    @latest.perform_query
  end

  def result
    unless @result
      results = latest.results.present? ? latest.results.first : {}
      @result = to_value(results)
    end

    @result
  end

  def period
    month = result[:"ukhpi:refMonth"]
    if month
      ref_month = to_value(month)
      date = Date.strptime(ref_month.value, '%Y-%m')
      date.strftime('%B %Y')
    else
      'Latest period not available'
    end
  end

  def house_price_index
    result
    first_value('ukhpi:housePriceIndex')
  end

  def average_price
    result
    first_value('ukhpi:averagePrice')
  end

  def percentage_monthly_change
    result
    format_percentage(first_value('ukhpi:percentageChange'))
  end

  def percentage_annual_change
    result
    format_percentage(first_value('ukhpi:percentageAnnualChange'))
  end

  private

  def first_value(key)
    @result[key.to_sym] ? @result[key.to_sym].first : 'unknown'
  end

  def to_value(val)
    DataServicesApi::Value.new(val.symbolize_keys)
  end

  def format_percentage(change)
    if change == 'unknown'
      change
    elsif change == 0.0
      'remained the same'
    elsif change.positive?
      format("risen by %.1f\%", change.abs)
    else
      format("fallen by %.1f\%", change.abs)
    end
  end
end
