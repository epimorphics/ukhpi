# frozen_string_literal: true

# Presenter for the state needed to drive the landing page
class LandingState
  attr_reader :latest, :user_selections

  def initialize(user_selections, lvc = LatestValuesCommand)
    @user_selections = user_selections
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
    month = result[:'ukhpi:refMonth']
    if month
      ref_month = to_value(month)
      date = Date.strptime(ref_month.value, '%Y-%m')

      # Uncomfortable choice here: we know that, in the Welsh translation, the
      # month will be preceded by 'O' (i.e. 'From'), which will trigger a mutation
      # for some month names. The mutation will only happen in Welsh-lang mode, but
      # we have to allow for that case so we apply the Grammar -> GrammarAction
      # transform even in English mode (where it's not really needed)
      Grammar
        .apply(source: I18n.l(date, format: '%B %Y'), assuming_prefix: 'o')
        .result
    else
      I18n.t('landing.not_available')
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

  def locale_partial
    "index_#{I18n.locale}"
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
    elsif change.zero?
      I18n.t('landing.change.same')
    elsif change.positive?
      format(
        '%<risen>s %<change>.1f%%',
        risen: I18n.t('landing.change.risen'),
        change: change.abs
      )
    else
      format(
        '%<fallen>s %<change>.1f%%',
        fallen: I18n.t('landing.change.fallen'),
        change: change.abs
      )
    end
  end
end
