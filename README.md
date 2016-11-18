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

Currently depends on Ruby version 2.2.x, since that matches the production
environment. Local Ruby version is specified by `.ruby-version`, assuming
that [rbenv](https://github.com/rbenv/rbenv) is used.

To install on dev machine:

    git clone git@github.com:epimorphics/ukhpi.git
    cd ukhpi
    bundle install

## Local data service

The application assumes that a Fuseki instance is running on `localhost:8080`. In
development, either start a local Fuseki instance, or, more usually, ssh tunnel
to one of the data servers. A predefined script for tunnelling one of the remote
data servers to localhost 8080 is provided in `bin/sr-tunnel-daemon`. A copy of
the ssh access credentials will need to be in your `~/.ssh/config`.

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

* *`ukhpi:regions_sparql`* <br />
  This task uses a SPARQL query to list all of the geographical regions in the UKHPI
  data, and their containment hierarchy, and generate cached versions of that data as
  code. In particular, it regenerates `app/assets/javascripts/regions-table.js` and
  `app/models/regions-table.rb`. This task should be re-run if and when the regions
  data from LR is changed in the triple store.

Note that, by default, SPARQL queries will be run against the dev triple store.
To direct the query against a different SPARQL endpoint, change the `SERVER` environment
variable:

    SERVER="http://lr-pres-staging-c.epimorphics.net/landregistry/query" rake ukhpi:regions_sparql

# Deployment

Deployment configuration is not managed by this repo, but is stored in the Chef recipes
and configurations. To update a development server, the desired changes should be merged
from the feature branch (or master if appropriate) into the `dev` branch. Then run
`sudo chef-client` on the server that needs to be updated. Similarly, staging servers
deploy from the `staging` branch and production servers from the `production` branch.

Note that updating production servers means that each server has to be dropped out of
the load balancer pool while `chef-client` runs.
