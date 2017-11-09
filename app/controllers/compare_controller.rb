# frozen-string-literal: true

# Controller for the user action of copmaring statistics between two or more
# locations
class CompareController < ApplicationController
  layout 'webpack_application'

  def show
    user_compare_selections = UserCompareSelections.new(params)
    query_results = perform_query(user_compare_selections) unless user_compare_selections.search?

    @view_state = CompareLocationsPresenter.new(user_compare_selections, query_results)
  end

  private

  def perform_query(user_compare_selections) # rubocop:disable Metrics/MethodLength
    query_results = {}
    base_selection = UserSelections.new(
      __safe_params: {
        from: user_compare_selections.from_date,
        to: user_compare_selections.to_date
      }
    )

    user_compare_selections.selected_locations.each do |location_id|
      location = Regions.lookup_gss(location_id)
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
