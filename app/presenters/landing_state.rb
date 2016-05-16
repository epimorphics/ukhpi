# Presenter for the state needed to drive the landing page

class LandingState
  attr_reader :latest

  def initialize
    @latest = LatestValuesCommand.new
    @latest.perform_query
  end

  def result
    @result ||= to_value( latest.results.first.symbolize_keys )
  end

  def period
    refPeriod = to_value( result[:"ukhpi:refPeriod"] )
    date = DateTime.strptime( refPeriod.value, "%Y-%m" )
    date.strftime( "%B %Y" )
  end

  def house_price_index
    result[:"ukhpi:housePriceIndex"].first
  end

  def average_price
    result[:"ukhpi:averagePrice"].first
  end

  def percentage_monthly_change
    format_percentage( result[:"ukhpi:percentageMonthlyChange"].first )
  end

  def percentage_annual_change
    format_percentage( result[:"ukhpi:percentageAnnualChange"].first )
  end

  :private

  def to_value( v )
    DataServicesApi::Value.new( v.symbolize_keys )
  end

  def format_percentage( change )
    if change == 0.0
      "remained the same"
    elsif change > 0
      "risen by %.1f\%" % change.abs
    else
      "fallen by %.1f\%" % change.abs
    end
  end
end
