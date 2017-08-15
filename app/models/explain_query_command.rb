# frozen_string_literal: true

# Explain query command
class ExplainQueryCommand < QueryCommand
  attr_reader :explanation

  def initialize(prefs)
    super
  end

  def perform_query(service = nil)
    hpi = service || dataset(:ukhpi)

    query = add_date_range_constraint(base_query)
    query = add_location_constraint(query)

    Rails.logger.debug "About to ask DsAPI to explain: #{query.to_json}"
    @explanation = hpi.explain(query)
  end

  def explain_query_command?
    true
  end
end
