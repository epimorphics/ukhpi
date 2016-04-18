# Presenter for the status of the search & query that the user has performed
class ExplorationState
  def initialize( cmd = nil )
    @cmd = cmd
  end

  # Return true if this presenter is encapsulating a query command
  def query?
    @cmd.respond_to?( :"query_command?" ) && @cmd.query_command?
  end

  def exception?
    @cmd.respond_to?( :[] ) && @cmd[:exception]
  end

  def empty?
    @cmd == nil
  end

  def partial_name( section )
    "#{state_name}_#{section}"
  end

  def state_name
    case
    when exception?
      :exception
    when empty?
      :empty_state
    when query?
      :query
    else
      :search
    end
  end
end
