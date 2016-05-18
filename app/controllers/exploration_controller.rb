class ExplorationController < ApplicationController
  def new
    begin
      @exploration_state = enact_search( collectUserPreferences )
    rescue ArgumentError => e
      @exploration_state = ExplorationState.new( exception: e )
    end

    respond_to do |format|
      format.json {render}
      format.html {render}
    end
  end

  def index
    @exploration_state = ExplorationState.new( collectUserPreferences )

    respond_to do |format|
      format.json {render}
      format.html {render}
    end
  end

  :private

  def enact_search( user_prefs )
    state = SearchCommand.new( user_prefs, Regions )

    if state.search_status == :single_result
      state = enact_query( state )
    end

    ExplorationState.new( state )
  end

  def collectUserPreferences
    UserPreferences.new( params )
  end

  def enact_query( search_cmd )
    qc = QueryCommand.new( search_cmd )
    qc.perform_query
    qc
  end

  def no_user_params?
    (params.keys - ["controller", "action"]).empty?
  end

end
