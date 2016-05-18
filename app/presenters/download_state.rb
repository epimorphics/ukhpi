# Presenter for download information

class DownloadState < Presenter

  STANDARD_COLUMNS = [
    {label: "Name", method: :name},
    {label: "URI", property: "ukhpi:refRegion"},
    {label: "GSS", method: :gss}
  ]


  def column_names
    (STANDARD_COLUMNS.map {|c| c[:label]}) + visible_aspects
  end

  def rows
    # TODO
    cmd.cmd.results.map {|r| as_row( r )}
  end

  def as_row( r )
    uri = r["ukhpi:refRegion"]["@id"]
    region = Regions.lookup_region( uri )

    [region.label, uri, region.gss]
  end
end
