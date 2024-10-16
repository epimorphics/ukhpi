# frozen_string_literal: true

# Controller for the main user experience of browsing the UKHPI statistics.
# Usually the primary interaction will be via JavaScript and XHR, but we also
# support non-JS access by setting browse preferences in the `edit` action.
class BrowseController < ApplicationController
  layout 'webpack_application'

  def show
    user_selections = UserSelections.new(params)

    if !user_selections.valid?
      render_request_error(user_selections, 400)
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
    { user_selections: user_selections, error: e.message }
  end

  def render_view_state(view_state)
    @view_state = view_state
    if view_state.respond_to?(:[]) && view_state[:error]
      Rails.logger.debug { "Application experienced an issue with this request: #{view_state}" } if Rails.env.development? # rubocop:disable Metrics/LineLength
      render_request_error(@view_state.user_selections, :internal_server_error)
    else
      respond_to do |format|
        format.html
        format.json { render json: @view_state }
      end
    end
  end

  # Look at the `action` parameter, which may be set by various action buttons
  # on the form, to determine whether we need to do any processing before
  # displaying the form
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
      flash[:search] = 'Missing search term' # rubocop:disable Rails/I18nLocaleTexts
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
    flash[:search] = 'Sorry, no locations match that search term' # rubocop:disable Rails/I18nLocaleTexts
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
    Rails.logger.info { "Redirecting to #{new_params}" } if Rails.env.development?
    redirect_to({
      controller: :browse,
      action: :show
    }.merge(new_params))
  end

  def render_request_error(user_selections, status)
    respond_to do |format|
      @view_state = { user_selections: user_selections }
      request_status = status == 400 ? :bad_request : :internal_server_error
      format.html do
        render 'exceptions/error_page',
               locals: { status: status, sentry_code: nil },
               layout: true,
               status: request_status
      end

      format.json do
        render(json: { status: 'request error' }, status: request_status)
      end
    end
  end
end
