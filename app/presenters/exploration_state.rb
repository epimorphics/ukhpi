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
end
