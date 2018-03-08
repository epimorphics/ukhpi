# frozen-string-literal: true

# Controller for the user action of copmaring statistics between two or more
# locations
class CompareController < ApplicationController
  layout 'webpack_application'

  def show
    if params.delete(:print)
      render_print
    else
      render_interactive
    end
  end

  private

  def setup_view_state
    user_compare_selections = UserCompareSelections.new(params)
    query_results = perform_query(user_compare_selections) unless user_compare_selections.search?

    @view_state = CompareLocationsPresenter.new(user_compare_selections, query_results)
  end

  def render_interactive
    setup_view_state
  end

  def render_print
    setup_view_state
    render 'compare/print', layout: 'print'
  end

  def perform_query(user_compare_selections) # rubocop:disable Metrics/MethodLength
    query_results = {}
    base_selection = UserSelections.new(
      __safe_params: {
        'from' => user_compare_selections.from_date,
        'to' => user_compare_selections.to_date
      }
    )

    user_compare_selections.selected_locations.each do |location|
      query_results[location.label] = query_with(base_selection, location)
    end

    query_results
  end

  def query_with(base_selection, location)
    selections = base_selection.with('location', location.uri)
    query_command = QueryCommand.new(selections)
    query_command.perform_query
    query_command.results
  end
end
