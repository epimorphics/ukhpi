# frozen_string_literal: true

# Presenter object that calculates the set of `DataView`s that should be
# created from a given `UserSelection`.
class DataViewsPresenter
  attr_reader :user_selections, :query_result

  def initialize(user_selections, query_result)
    @user_selections = user_selections
    @query_result = query_result
  end

  def data_views
    @data_views ||= ukhpi.themes.each_key.map do |theme_name|
      as_data_views(ukhpi.theme(theme_name), true)
    end.flatten
  end

  def to_json(_options = {})
    JSON.dump(
      results: query_result,
      selections: data_views.first.as_js_attributes
    )
  end

  def each_theme_with_views(&block)
    first = true

    ukhpi.themes.each_key do |theme_name|
      theme = ukhpi.theme(theme_name)
      data_views = as_data_views(theme, first)
      first = false

      block.yield(theme, data_views)
    end
  end

  delegate :explain?, to: :user_selections

  private

  # @return An array of data view objects
  def as_data_views(theme, is_first)
    data_views = theme.indicators.map do |indicator|
      DataView.new(user_selections: user_selections, query_result: query_result,
                   indicator: indicator, theme: theme)
    end

    data_views.first.first = is_first
    data_views
  end

  def ukhpi
    @ukhpi ||= UkhpiDataCube.new
  end
end
