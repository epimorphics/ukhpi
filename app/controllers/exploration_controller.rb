class ExplorationController < ApplicationController
  def new
    begin
      enact_search( collectUserPreferences )
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
    search_cmd = SearchCommand.new( user_prefs, Regions )

    if search_cmd.search_status == :single_result
      @exploration_state = ExplorationState.new( enact_query( search_cmd ) )
    else
      @exploration_state = ExplorationState.new( search_cmd )
    end
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
