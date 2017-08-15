# frozen_string_literal: true

# Presenter for the status of the search & query that the user has performed
class ExplorationState < Presenter
  include Rails.application.routes.url_helpers

  MAX_SEARCH_RESULTS = 20

  def partial_name(section)
    "#{state_name}_#{section}"
  end

  def results_summary
    count = cmd.results.length
    display_count = [MAX_SEARCH_RESULTS, count].min
    count == if display_count
               format(I18n.t('index.show_all_results'), count)
             else
               format(I18n.t('index.show_some_results'), display_count, count)
             end
  end

  # rubocop:disable Metrics/MethodLength
  def results_list
    cmd
      .results
      .values
      .sort
      .take(MAX_SEARCH_RESULTS)
      .map do |result|
        pw = prefs.with(:region, result.uri)
        uri = url_for({
          only_path: true,
          controller: :exploration,
          action: :new
        }.merge(pw))
        { label: result.label, uri: uri }
      end
  end

  private

  def state_name
    if exception?
      :exception
    elsif query?
      :query
    elsif search?
      :search
    else
      :empty_state
    end
  end
end
