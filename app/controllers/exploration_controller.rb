# frozen_string_literal: true

# :nodoc:
class ExplorationController < ApplicationController
  def new
    begin
      @exploration_state = enact_search(collect_user_preferences)
    rescue ArgumentError => e
      @exploration_state = ExplorationState.new(exception: e)
    end

    respond_to do |format|
      format.json { render }
      format.html { render }
    end
  end

  def index
    @exploration_state = ExplorationState.new(collect_user_preferences)

    respond_to do |format|
      format.json { render }
      format.html { render }
    end
  end

  private

  def enact_search(user_prefs)
    state = SearchCommand.new(user_prefs, Regions)

    if state.search_status == :single_result
      state = explain_or_enact_query state
    end

    ExplorationState.new(state)
  end

  def collect_user_preferences
    UserPreferences.new(ActionController::Parameters.new(params))
  end

  def explain_or_enact_query(search_cmd)
    qc = params[:explain] ? explain_query(search_cmd) : enact_query(search_cmd)
    qc.perform_query
    qc
  end

  def enact_query(search_cmd)
    QueryCommand.new(search_cmd)
  end

  def explain_query(search_cmd)
    ExplainQueryCommand.new(search_cmd)
  end

  def no_user_params?
    (params.keys - %w[controller action]).empty?
  end
end
