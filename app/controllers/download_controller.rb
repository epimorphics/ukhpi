# :nodoc:
class DownloadController < ExplorationController
  def new # rubocop:disable Metrics/MethodLength
    begin
      download = enact_search(collect_user_preferences)
      @download_state = DownloadState.new(download)
    rescue ArgumentError => e
      @download_state = DownloadState.new(exception: e)
    end

    respond_to do |format|
      format.json do
        render_attachment(synthesise_filename(@download_state, 'json'), 'application/json')
      end

      format.html { render }
      format.csv { render_attachment(synthesise_filename(@download_state, 'csv'), 'text/csv') }
    end
  end

  private

  def render_attachment(filename, mime_type)
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers['Content-type'] = 'text/plain'
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Expires'] = '0'
    else
      headers['Content-Type'] ||= mime_type
    end

    headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""

    render layout: false
  end

  def synthesise_filename(download_state, extension)
    "ukhpi-#{download_state.as_filename}.#{extension}"
  end
end
