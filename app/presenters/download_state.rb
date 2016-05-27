# Presenter for download information

class DownloadState < Presenter

  STANDARD_COLUMNS = [
    {label: "Name"},
    {label: "URI"},
    {label: "GSS"},
    {label: "Period"}
  ]


  def column_names
    (STANDARD_COLUMNS.map {|c| c[:label]}) + visible_aspects
  end

  def rows
    cmd.cmd.results.map {|r| as_row( r )}
  end

  def as_row( r )
    uri = r["ukhpi:refRegion"]["@id"]
    region = Regions.lookup_region( uri )
    date = r["ukhpi:refPeriod"]["@value"]
    region_label = "\'#{region.label}\'"

    [region_label, uri, region.gss, date] + visible_aspects.map {|a| r["ukhpi:#{a}"]}
  end

  def as_filename
    prefs
      .summary
      .gsub( /[ [[:punct:]]]/, "-" )
      .gsub( "--", "-" )
      .downcase
      .strip
  end
end
