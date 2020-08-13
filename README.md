# UKHPI open data application

![Rails CI test](https://github.com/epimorphics/ukhpi/workflows/Rails%20CI%20test/badge.svg)

This is the repo for the application that presents UKHPI open data on behalf
of Land Registry (England and Wales), Registers of Scotland, Land and Property
Services (Northern Ireland) and the UK Office for National Statistics.

Development work was carried out by [Epimorphics Ltd](http://www.epimorphics.com),
funded by [HM Land Registry](https://www.gov.uk/government/organisations/land-registry).

Code in this repository is open-source under the MIT license. The UKHPI data
itself is freely available under the terms of the
[Open Government License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

## Developer notes

### Installation dependencies

Currently depends on Ruby version 2.6.x, since that matches the production
environment. Local Ruby version is specified by `.ruby-version`, assuming
that [rbenv](https://github.com/rbenv/rbenv) is used.

To install on dev machine:

    git clone git@github.com:epimorphics/ukhpi.git
    cd ukhpi
    bundle install
    yarn install

### Local data service

The application assumes that a Fuseki instance is running on `localhost:8080`. In
development, either start a local Fuseki instance, or, more usually, ssh tunnel
to one of the data servers. A predefined script for tunnelling one of the remote
data servers to localhost 8080 is provided in `bin/sr-tunnel-daemon`. A copy of
the ssh access credentials will need to be in your `~/.ssh/config`.

### Outline domain model

In the 2017 update, we're extending the display to present all of the underlying
statistics calculated by ONS. In addition to the figures by property type
(all, detached houses, semi-detached, terraced and flat/maisonette),
there are also figures for property status (new build vs. existing),
buyer status (first-time buyer or not), and funding status (paid cash or bought
with a mortgage).  For each of these figures, multiple
indicators are calculated: the statistical index, the percentage change (monthly
and annual) and the average price. For some of the statistics, a sales volume
indicator is also available.

We represent these as follows:

| theme | indicator | statistic |
| --- | --- | --- |
| Type of property | index | All property types |
|  | average price | All property types |
|  | % monthly change | All property types |
|  | % annual change | All property types |
|  | sales volume | All property types |
|  | index | Detached houses |
|  | average price | Detached houses |
|  | % monthly change | Detached houses |
|  | % annual change | Detached houses |
|  | index | Semi-detached houses |
|  | average price | Semi-detached houses |
|  | % monthly change | Semi-detached houses |
|  | % annual change | Semi-detached houses |
|  | index | Terraced houses |
|  | average price | Terraced houses |
|  | % monthly change | Terraced houses |
|  | % annual change | Terraced houses |
|  | index | Flats and maisonettes |
|  | average price | Flats and maisonettes |
|  | % monthly change | Flats and maisonettes |
|  | % annual change | Flats and maisonettes |
| Buyer status | index | First-time buyers |
|  | average price | First-time buyers |
|  | % monthly change | First-time buyers |
|  | % annual change | First-time buyers |
|  | index | Former owner-occupiers |
|  | average price | Former owner-occupiers |
|  | % monthly change | Former owner-occupiers |
|  | % annual change | Former owner-occupiers |
| Funding status | index | Cash purchases |
|  | average price | Cash purchases |
|  | % monthly change | Cash purchases |
|  | % annual change | Cash purchases |
|  | sales volume | Cash purchases |
|  | index | Mortgage purchases |
|  | average price | Mortgage purchases |
|  | % monthly change | Mortgage purchases |
|  | % annual change | Mortgage purchases |
|  | sales volume | Mortgage purchases |
| Property status | index | New build |
|  | average price | New build |
|  | % monthly change | New build |
|  | % annual change | New build |
|  | sales volume | New build
|  | index | Existing properties |
|  | average price | Existing properties |
|  | % monthly change | Existing properties |
|  | % annual change | Existing properties |
|  | sales volume | Existing properties

### Rails script tasks

Some development tasks are handled by automated Rails task scripts. All tasks code is
in `./lib/tasks/*.rake`. You can list all of the tasks with `rails -T`. The mostly
commonly useful ones are:

* *`test`*\
  Run the test suite

* *`ukhpi:aspects`*\
  Generate a JavaScript description of the DSD aspects, as described by the
  `DataModel` class, which directly translates from the `UKHPI-dsd.ttl` file

* *boundaries tasks*\
  A number of tasks releated to generating simplified GeoJSON files from the Shapefiles downloaded
  from ONS. These tasks will need to be re-run when the boundaries change,
  e.g. when local authorities are merged or split to form new unitary authorities.
  See below for more details.

* *`ukhpi:describe[uri]`*\
  A convenient way to perform a SPARQL describe for the given URI

* *`ukhpi:locations`*\
  This task uses a SPARQL query to list all of the geographical regions in the UKHPI
  data, and their containment hierarchy, and generate cached versions of that data as
  code. In particular, it regenerates `app/javascript/data/locations-data.js` and
  `app/models/locations_table.rb`. This task should be re-run if and when the regions
  data from LR is changed in the triple store.

Note that, by default, SPARQL queries will be run against the dev triple store.
To direct the query against a different SPARQL endpoint, change the `SERVER` environment
variable:

    SERVER="https://lr-dev.epimorphics.net/landregistry/query" rails ukhpi:locations

## Deployment

We are moving to a new deployment pattern, based around Docker files. The `Makefile`
provides a list of make targets to create and run a Docker image for UKHPI. Run
`make help` to get a list of available targets.

More details on the new deployment process will be added in future.

## Updating geographies

Many years, the boundaries of UK local authorities change. Sometimes mutliple adjacent
authorities merge to for a new unitary authority, or sometimes a unitary authority
is split off from an existing LA (e.g. City of Plymouth). In this case, we need to
update two data sources with the application, and coordinate this change with HMLR
(and, by extension, ONS)

In 2020, we updated the app due to various changes in LA boundaries, including the
creation of the Bournemouth, Christchurch and Poole UA. The timeline of these changes
was fairly typical, so I'm documenting it here for future reference:

* April 2019: new boundaries go into effect
* Feb 2020: ONS perform their (single) yearly update of location tables
* March 2020: HMLR provided Epimorphics with a collection of test data, including
  the new regions table, as Turtle (`.ttl`) files
* March 2020: we loaded the test data into a dev server, in order to re-run
  the `rails ukhpi:locations` task. This updates the cached Ruby and Javascript
  locations tables, to save the application having to query the API every time
  a location is referred to
* In order to update the map UI in UKHPI, we need to regenerate the `ONS-Geographies`
  GeoJSON file. [Alex](mailto:alex.coley@epimorphics.com) has an FME script on
  his system that automates this. The basic process is: find and download the
  relevant shapefile from the ONS geographies portal, then run the script to
  convert the shapefile GeoJSON, simplifying the outlines along the way. We
  need to simplify the outlines, because otherwise the generated GeoJSON file
  is enormous. Doing the simplification in FME means that there are no gaps
  between adjacent authorities as the outlines are compressed. Once the initial
  GeoJSON file is produced, there is a simple shellscript to regularise the
  property names in the GeoJSON. See `bin/ons-geojson-cleanup`. The core issue
  is that the application code expects the GSS code for a location to be `code`
  and the location name to be `name`. In the ONS shapefile, the GSS code can be,
  for example, `rgn18cd` and the name `rgn18nm`. Rather than have the code
  adapt to these (I'm assuming they may change each year), it was easier to have
  a data-cleansing task. It could have been a rake task, but there are some
  Linux command utilities that do the job very easily. The code will need to
  be changed to reference the new GeoJSON file, i.e.
  `app/javascript/data/ONS-Geographies-$YEAR.json`.
* Finally, the application is published on `dev` for the Plymouth team to test.