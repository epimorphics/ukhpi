# UKHPI Rails application

This is the repo for the application that presents UKHPI open data on behalf
of Land Registry (England and Wales), Registers of Scotland, Land and Property
Services (Northern Ireland) and the UK Office for National Statistics.

Development work was carried out by [Epimorphics Ltd](http://www.epimorphics.com),
funded by [Land Registry](https://www.gov.uk/government/organisations/land-registry).

Code in this repository is open-source under the MIT license. The UKHPI data
itself is freely available under the terms of the
[Open Government License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

# Developer notes

## Installation dependencies

Currently depends on Ruby version 2.4.x, since that matches the production
environment. Local Ruby version is specified by `.ruby-version`, assuming
that [rbenv](https://github.com/rbenv/rbenv) is used.

To install on dev machine:

    git clone git@github.com:epimorphics/ukhpi.git
    cd ukhpi
    bundle install
    yarn install

## Local data service

The application assumes that a Fuseki instance is running on `localhost:8080`. In
development, either start a local Fuseki instance, or, more usually, ssh tunnel
to one of the data servers. A predefined script for tunnelling one of the remote
data servers to localhost 8080 is provided in `bin/sr-tunnel-daemon`. A copy of
the ssh access credentials will need to be in your `~/.ssh/config`.

## Outline domain model

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

## Rake tasks

Some development tasks are handled by automated Rake scripts. All Rake tasks code is
in `./lib/tasks/*.rake`. You can list all of the tasks with `rake -T`. The mostly
commonly useful ones are:

* *`test`* <br />
  Run the test suite

* *`ukhpi:aspects`* <br />
  Generate a JavaScript description of the DSD aspects, as described by the
  `DataModel` class, which directly translates from the `UKHPI-dsd.ttl` file

* *boundaries tasks* <br />
  A number of tasks releated to generating simplified GEOJSON files from the Shapefiles downloaded
  from ONS. These tasks do not generally need to be re-run

* *`ukhpi:describe[uri]`* <br />
  A convenient way to perform a SPARQL describe for the given URI

* *`ukhpi:locations`* <br />
  This task uses a SPARQL query to list all of the geographical regions in the UKHPI
  data, and their containment hierarchy, and generate cached versions of that data as
  code. In particular, it regenerates `app/javascript/data/locations-data.js` and
  `app/models/locations_table.rb`. This task should be re-run if and when the regions
  data from LR is changed in the triple store.

Note that, by default, SPARQL queries will be run against the dev triple store.
To direct the query against a different SPARQL endpoint, change the `SERVER` environment
variable:

    SERVER="http://lr-pres-staging-c.epimorphics.net/landregistry/query" rake ukhpi:locations

# Deployment

Deployment configuration is not managed by this repo, but is stored in the Chef recipes
and configurations. To update a development server, the desired changes should be merged
from the feature branch (or master if appropriate) into the `dev` branch. Then run
`sudo chef-client` on the server that needs to be updated. Similarly, staging servers
deploy from the `staging` branch and production servers from the `production` branch.

Note that updating production servers means that each server has to be dropped out of
the load balancer pool while `chef-client` runs.
