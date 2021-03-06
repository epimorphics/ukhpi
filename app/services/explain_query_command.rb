# frozen_string_literal: true

# Explain query command. This is an extension of the QueryCommand, and differs
# only that it asks the DsAPI to explain its query strategy, rather than performing
# the query.
class ExplainQueryCommand < QueryCommand
  # Explain the given query, and stash the results. Return time taken in ms.
  def execute_query(service, query)
    start = Time.zone.now
    @results = api_service(service).explain(query)
    (Time.zone.now - start) * MILLISECONDS
  end

  def query_command?
    false
  end

  def explain_query_command?
    true
  end
end
