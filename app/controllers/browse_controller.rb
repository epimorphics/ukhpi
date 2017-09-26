# frozen-string-literal: true

# Controller for the main user experience of browsing the UKHPI statistics.
# Usually the primary interaction will be via JavaScript and XHR, but we also
# support non-JS access by setting browse preferences in the `edit` action.
class BrowseController < ApplicationController
  def show
    user_selections = UserSelections.new(params)
    query_command = QueryCommand.new(user_selections)
    query_command.perform_query

    @view_state = DataViewsPresenter.new(user_selections, query_command.results)
  end

  def edit
    @view_state = BrowseEditViewState.new(params)
    process_form_action(@view_state)
  end

  # private

  # Look at the `action` parameter, which may be set by various action buttons
  # on the form, to determine whether we need to do any processing before
  # dislaying the form
  def process_form_action(view_state)
    action = view_state.user_selections.action

    case action&.downcase
    when 'search'
      search_for_location(view_state)
    when 'view'
      view_result(view_state)
    end
  end

  # User clicked the search button
  def search_for_location(view_state)
    if !view_state.location_search_term&.empty?
      match_location(view_state)
    else
      flash[:search] = 'Missing search term'
    end
  end

  def match_location(view_state)
    locations = Locations.search_location(view_state.location_search_term,
                                          view_state.location_search_type)

    case locations.length
    when 0
      match_no_locations
    when 1
      match_single_location(view_state, locations)
    else
      match_multiple_locations(view_state, locations)
    end
  end

  def match_no_locations
    flash[:search] = 'Sorry, no locations match that search term'
  end

  def match_single_location(view_state, locations)
    view_state.location = locations.first
  end

  def match_multiple_locations(view_state, locations)
    view_state.add_matched_locations(locations)
    view_state.user_selections.clear_selected_location
  end

  def view_result(view_state)
    new_params = view_state.user_selections.without('form-action', nil).params
    Rails.logger.debug "Redirecting to #{new_params}"
    redirect_to({
      controller: :browse,
      action: :show
    }.merge(new_params))
  end
end
