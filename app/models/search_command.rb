# Decorator which encapsulates an interpretation of the user preferences as a region search

class SearchCommand
  attr_reader :prefs, :regions, :results

  def initialize( prefs, regions )
    @prefs = prefs
    @regions = regions
    @results = nil
    @region = nil
  end

  def method_missing( method, *args, &block )
    @prefs.send( method, *args, &block )
  end

  # Return one of :no_results, :single_result, :multiple_results depending
  # on the number of locations that match the search term
  def search_status
    if uri_term?
      :single_result
    else
      perform_search
    end
  end

  def uri_term?
    @region = region.match( /\Ahttp:\/\// ) && regions.lookup_region( region )
  end

  def perform_search
    @results = regions.match( region )
    case @results.size
    when 0
      :no_results
    when 1
      @region = @results.first
      :single_result
    else
      :multiple_results
    end
  end

  def region_uri
    @region && @region.uri
  end
end
