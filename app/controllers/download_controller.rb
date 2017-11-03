# frozen_string_literal: true

# Controller for the action of downloading UKHPI data in a variety of data formats
# (csv, json, RDF etc)
class DownloadController < ExplorationController
  def new
    user_selections = UserSelections.new(params)
    query_command = QueryCommand.new(user_selections)
    query_command.perform_query

    format_download_results(query_command)
  end

  private

  def format_download_results(query_command)
    respond_to do |format|
      format.json do
        render_attachment(query_command, 'json', 'application/json')
      end

      format.csv do
        render_attachment(query_command, 'csv', 'text/csv')
      end
    end
  end

  def render_attachment(query_command, extension, mime_type)
    filename = synthesise_filename(query_command, extension)
    update_response_headers(filename, mime_type)
    presenter = DownloadPresenter.new(query_command)

    render layout: false, locals: { download_presenter: presenter }
  end

  def synthesise_filename(query_command, extension)
    summary = query_command.user_selections.summary
    file_root = summary.downcase.gsub(/\s|[[:punct:]]/, '-')
    "ukhpi-#{file_root}.#{extension}"
  end

  def update_response_headers(filename, mime_type)
    if internet_explorer?
      headers['Pragma'] = 'public'
      headers['Content-type'] = 'text/plain'
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Expires'] = '0'
    else
      headers['Content-Type'] ||= mime_type
    end

    headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
  end

  def internet_explorer?
    request.env['HTTP_USER_AGENT'].match?(/msie/i)
  end
end
