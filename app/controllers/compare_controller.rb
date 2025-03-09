# frozen_string_literal: true

# Controller for the user action of copmaring statistics between two or more
# locations
class CompareController < ApplicationController
  layout 'webpack_application'

  def show
    if params.delete(:print)
      render_print
    else
      render_interactive(setup_view_state)
    end
  end

  private

  def setup_view_state
    LoggingHelper.log_request({ params: params, path: request.path })
    user_compare_selections = UserCompareSelections.new(params)
    query_results = perform_query(user_compare_selections) unless user_compare_selections.search?

    CompareLocationsPresenter.new(user_compare_selections, query_results)
  rescue ArgumentError => e
    { user_selections: user_compare_selections, error: e.message }
  end

  def render_interactive(view_state)
    @view_state = view_state
    if view_state.respond_to?(:[]) && view_state[:error]
      render_request_error(@view_state[:user_selections], :internal_server_error) unless Rails.env.development? # rubocop:disable Layout.LineLength
    else
      @view_state
    end
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
      msg = 'Received Data Services API request from UKHPI service'
      msg += " for #{location.label}" if location
      log_fields = { params: base_selection.with('location', location.uri) }
      log_fields[:message] = msg
      LoggingHelper.log_request(log_fields)
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
