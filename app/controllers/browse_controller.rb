# frozen-string-literal: true

# Controller for the main user experience of browsing the UKHPI statistics.
# Usually the primary interaction will be via JavaScript and XHR, but we also
# support non-JS access by setting browse preferences in the `edit` action.
class BrowseController < ApplicationController # rubocop:disable Metrics/ClassLength
  layout 'webpack_application'

  def show
    user_selections = UserSelections.new(params)

    if !user_selections.valid?
      render_bad_request
    elsif explain_non_json?(user_selections)
      redirect_to_html_view(user_selections)
    else
      render_view_state(setup_view_state(user_selections))
    end
  end

  def edit
    @view_state = BrowseEditViewState.new(params)
    process_form_action(@view_state)
  end

  private

  # @return The appropriate query command class
  def query_command
    params[:explain] ? ExplainQueryCommand : QueryCommand
  end

  # Return true if the user has requested the explain-results action, but not with Mime
  # type JSON. JSON is the normal case for explain. Other cases, such as explain with HTML
  # type, are usually search bots being a pest
  def explain_non_json?(user_selections)
    user_selections.explain? && !request.format.json?
  end

  def redirect_to_html_view(user_selections)
    url_params = user_selections.params
    url_params.delete('explain')

    redirect_to({
      controller: :browse,
      action: :show
    }.merge(url_params))
  end

  def setup_view_state(user_selections)
    command = query_command.new(user_selections)
    command.perform_query

    DataViewsPresenter.new(user_selections, command.results)
  rescue ArgumentError => e
    { error: e.message }
  end

  def render_view_state(view_state)
    if view_state.respond_to?(:'[]') && view_state[:error]
      render plain: "Bad request: #{view_state[:error]}", status: :bad_request
    else
      @view_state = view_state

      respond_to do |format|
        format.html
        format.json { render json: @view_state }
      end
    end
  end

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
    if view_state.location_search_term.present?
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

  def render_bad_request # rubocop:disable Metrics/MethodLength
    respond_to do |format|
      format.html do
        render 'exceptions/error_page',
               locals: { status: 400, sentry_code: nil },
               layout: true,
               status: :bad_request
      end

      format.json do
        render(json: { status: 'bad request' }, status: :bad_request)
      end
    end
  end
end
