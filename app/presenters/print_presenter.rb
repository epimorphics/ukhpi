# frozen_string_literal: true

# A presenter for the printable view, based on the download view presenter
class PrintPresenter < DownloadPresenter # rubocop:disable Metrics/ClassLength
  include ActionView::Helpers::NumberHelper

  PRINT_COLUMNS = [
    DownloadColumn.new(
      label: '',
      format: lambda do |row|
        ValueFormatter.month_year(row['ukhpi:refMonth']['@value'])
          .gsub(' ', '&nbsp;')
          .html_safe
      end
    ),
    DownloadColumn.new(
      label: I18n.t('browse.print.reporting_period').html_safe,
      format: lambda do |row|
        key = row['ukhpi:refPeriodDuration'].first == 3 ? 'quarterly' : 'monthly'
        val = I18n.t("browse.print.#{key}")
        "<div class='u-text-centre'>#{val}</div>".html_safe
      end
    ),
    DownloadColumn.new(
      label: I18n.t('statistic.volume'),
      format: lambda do |row|
        val = row['ukhpi:salesVolume'].first
        "<div class='u-text-right'>#{val}</div>".html_safe
      end
    )
  ].freeze

  SALES_VOLUME_COL = 2 # PRINT_COLUMNS.map(&:label).index('Sales volume')

  def locations
    @locations ||=
      Array(user_selections.selected_location)
      .map { |uri| Locations.lookup_location(uri) }
  end

  def in_location
    in_loc = "#{I18n.t('preposition.in')} #{locations.first.label}"
    WelshGrammar
      .apply(source: in_loc, prefix: I18n.t('preposition.in'))
      .result
  end

  def indicators
    user_selections
      .selected_indicators
      .map { |slug| ukhpi.indicator(slug) }
  end

  def indicator_summary
    indicators
      .map(&:label)
      .join(I18n.t('connective.and'))
  end

  def statistics
    user_selections
      .selected_statistics
      .map { |slug| ukhpi.statistic(slug) }
  end

  def statistic_summary
    statistics
      .map(&:label)
      .join(I18n.t('connective.and'))
  end

  def themes
    user_selections
      .selected_themes
      .map { |slug| ukhpi.theme(slug) }
  end

  def theme_summary
    themes
      .map(&:label)
      .join(I18n.t('connective.and'))
  end

  def dates
    @dates ||=
      [
        user_selections.from_date,
        user_selections.to_date
      ]
  end

  def dates_summary
    dates
      .map { |date| I18n.l(date, format: '%B %Y') }
      .join(' &ndash; ')
      .html_safe
  end

  def column_names
    columns.map(&:label)
  end

  private

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end

  def columns
    return @columns if @columns

    @columns = PRINT_COLUMNS + user_selection_columns
    @columns.delete_at(SALES_VOLUME_COL) if selected_indicators.map(&:slug).include?('vol')
    @columns
  end

  def user_selection_columns
    selected_statistics.map(&method(:statistic_indicator_columns)).flatten
  end

  # @return An array of the given statistic paired with the currently selected
  # indicators
  def statistic_indicator_columns(stat) # rubocop:disable Metrics/MethodLength
    selected_indicators.map do |ind|
      DownloadColumn.new(
        ind: ind,
        stat: stat,
        sep: '<br />',
        format: lambda do |row|
          val = row["ukhpi:#{ind&.root_name}#{stat.root_name}"].first
          ValueFormatter.format(val,
                                slug: ind&.root_name,
                                template: "<div class='u-text-right'>%<formatted>s</div>")
        end
      )
    end
  end
end
