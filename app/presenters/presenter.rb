# frozen_string_literal: true

# Common shared code for UKHPI presenters
class Presenter
  attr_reader :cmd

  def initialize(cmd = nil)
    @cmd = cmd
  end

  # Return true if this presenter is encapsulating an explain query command
  def explain_query?
    @cmd.respond_to?(:"query_command?") && @cmd.explain_query_command?
  end

  # Return true if this presenter is encapsulating a query command
  def query?
    @cmd.respond_to?(:"query_command?") && @cmd.query_command?
  end

  # Return true if this presenter is encapsulating a search command
  def search?
    @cmd.respond_to?(:search_status)
  end

  def exception?
    @cmd.respond_to?(:[]) && @cmd[:exception]
  end

  def empty?
    @cmd.nil?
  end

  def prefs
    @cmd.respond_to?(:prefs) && @cmd.prefs
  end

  def preference(key)
    prefs && prefs.send(key)
  end

  def query_results
    @cmd.results
  end

  def query_explanation
    @cmd.explanation
  end

  def visible_aspects
    aspects.visible_aspects
  end

  def aspect(key)
    aspects.aspect(key)
  end

  def aspects
    @aspects ||= Aspects.new(@cmd.prefs)
  end

  def lookup_location(r)
    Locations.lookup_location(r)
  end
end
