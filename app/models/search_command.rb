# frozen_string_literal: true

# Decorator which encapsulates an interpretation of the user preferences as a region search
class SearchCommand
  attr_reader :prefs, :regions, :results

  def initialize(prefs, regions)
    @prefs = prefs
    @regions = regions
    @results = nil
    @region = nil
  end

  def method_missing(method, *args, &block)
    if @prefs.respond_to?(method)
      @prefs.send(method, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(_method, _args = nil)
    true
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
    @region = region.match(%r{\Ahttp://}) && regions.lookup_region(region)
  end

  def query_command?
    false
  end

  private

  def perform_search
    @results = regions.match(region, prefs)
    case @results.size
    when 0
      :no_results
    when 1
      @region = @results.values.first
      :single_result
    else
      :multiple_results
    end
  end

  def region_uri
    @region && @region.uri
  end
end
