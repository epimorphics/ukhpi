# Presenter for the status of the search & query that the user has performed
class ExplorationState
  include Rails.application.routes.url_helpers

  MAX_SEARCH_RESULTS = 20

  attr_reader :cmd

  def initialize( cmd = nil )
    @cmd = cmd
  end

  # Return true if this presenter is encapsulating a query command
  def query?
    @cmd.respond_to?( :"query_command?" ) && @cmd.query_command?
  end

  # Return true if this presenter is encapsulating a search command
  def search?
    @cmd.respond_to?( :"search_status" )
  end

  def exception?
    @cmd.respond_to?( :[] ) && @cmd[:exception]
  end

  def empty?
    @cmd == nil
  end

  def prefs
    @cmd.respond_to?( :prefs ) && @cmd.prefs
  end

  def partial_name( section )
    "#{state_name}_#{section}"
  end

  def results_summary
    count = cmd.results.length
    display_count = [MAX_SEARCH_RESULTS, count].min
    (count == display_count) ?
      sprintf( I18n.t( "index.show_all_results" ), count ) :
      sprintf( I18n.t( "index.show_some_results" ), display_count, count )
  end

  def results_list
    cmd
      .results
      .values
      .sort
      .take( MAX_SEARCH_RESULTS )
      .map do |result|
        pw = prefs.with( :region, result.uri )
        uri = url_for( {
          only_path: true,
          controller: :exploration,
          action: :new
        }.merge( pw ) )
        {label: result.label, uri: uri}
      end
  end

  def preference( key )
    prefs && prefs.send( key )
  end

  def query_results
    @cmd.results
  end

  def visible_aspects
    aspects.visible_aspects
  end

  def aspect( key )
    aspects.aspect( key )
  end

  def aspects
    @aspects ||= Aspects.new( @cmd.prefs )
  end

  :private

  def state_name
    case
    when exception?
      :exception
    when query?
      :query
    when search?
      :search
    else
      :empty_state
    end
  end
end
