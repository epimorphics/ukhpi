class DownloadController < ExplorationController
  def new
    begin
      download = enact_search( collectUserPreferences )
      @download_state = DownloadState.new( download )
    rescue ArgumentError => e
      @download_state = DownloadState.new( exception: e )
    end

    respond_to do |format|
      format.json {render}
      format.html {render}
      format.csv {render}
    end
  end

end
