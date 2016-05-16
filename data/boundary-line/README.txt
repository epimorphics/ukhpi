# Boundary line generation

We use Open Boundary Line data from OS to generate the outlines
of counties and regions on the maps. This section of the project
is for regenerating the artefacts we use, by processing the shape
files and down-sampling the regions.

To regenerate the boundary lines, a copy of the boundary line data
is required. Since this is large, we don't include it in the checked-in
project; instead a fresh copy should be downloaded from:

https://www.ordnancesurvey.co.uk/opendatadownload/products.html

The archive unpacks into the ./Data and ./Doc directories.
