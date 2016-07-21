# Presenter for the state needed to drive the landing page

class LandingState
  attr_reader :latest

  def initialize( lvc = LatestValuesCommand )
    @latest = lvc.new
    @latest.perform_query
  end

  def result
    results = (latest.results && !latest.results.empty?) ? latest.results.first : Hash.new
    @result ||= to_value( results )
  end

  def period
    month = result[:"ukhpi:refMonth"]
    if month
      refMonth = to_value( month )
      date = DateTime.strptime( refMonth.value, "%Y-%m" )
      date.strftime( "%B %Y" )
    else
      "Latest period not available"
    end
  end

  def house_price_index
    first_value( "ukhpi:housePriceIndex" )
  end

  def average_price
    first_value( "ukhpi:averagePrice" )
  end

  def percentage_monthly_change
    format_percentage( first_value( "ukhpi:percentageChange" ) )
  end

  def percentage_annual_change
    format_percentage( first_value( "ukhpi:percentageAnnualChange" ) )
  end

  :private

  def first_value( key )
    @result[key.to_sym] ? @result[key.to_sym].first : "unknown"
  end

  def to_value( v )
    DataServicesApi::Value.new( v.symbolize_keys )
  end

  def format_percentage( change )
    if change == "unknown"
      change
    elsif change == 0.0
      "remained the same"
    elsif change > 0
      "risen by %.1f\%" % change.abs
    else
      "fallen by %.1f\%" % change.abs
    end
  end
end
