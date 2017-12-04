# frozen_string_literal: true

# Controller for the action of downloading UKHPI data in a variety of data formats
# (csv, json, RDF etc)
class DownloadController < ApplicationController
  def new
    if params[:location].is_a?(Array)
      download_multiple_locations
    else
      download_single_location
    end
  end

  private

  # Create a download file for just a single location
  def download_single_location
    user_selections = UserSelections.new(params)
    query_command = QueryCommand.new(user_selections)
    query_command.perform_query

    format_download_results(query_command)
  end

  def download_multiple_locations
    pparams = params.permit('from', 'to', 'in', 'st', 'location' => [])
    location_gss = pparams.delete('location')
    locations = location_gss.map { |gss| Locations.lookup_gss(gss).uri }

    query_commands = locations.map do |location|
      query_params = ActionController::Parameters.new(location: location).merge(pparams)
      QueryCommand.new(UserSelections.new(query_params))
    end

    format_download_results(query_commands)
  end

  def format_download_results(query_commands)
    respond_to do |format|
      format.json do
        render_attachment(query_commands, 'json', 'application/json')
      end

      format.csv do
        render_attachment(query_commands, 'csv', 'text/csv')
      end
    end
  end

  def render_attachment(query_commands, extension, mime_type)
    filename = synthesise_filename(query_commands, extension)
    update_response_headers(filename, mime_type)
    presenter = DownloadPresenter.new(query_commands)

    render layout: false, locals: { download_presenter: presenter }
  end

  def synthesise_filename(query_commands, extension)
    summary = query_commands.first.user_selections.summary
    file_root = summary.downcase.gsub(/\s|[[:punct:]]/, '-')
    comparison = query_commands.length > 1 ? 'comparison-' : ''
    "ukhpi-#{comparison}#{file_root}.#{extension}"
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
