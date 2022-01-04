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

### Connecting to the data service

The application needs to connect to a data API, based on
[SapiNT](https://github.com/epimorphics/sapi-nt), to provide JSON-API access to
the data in the triple store. The base URL for the data API needs to be passed
as an environment variable `API_SERVICE_URL`. In production deployments, the
`API_SERVICE_URL` will be set by Ansible configuration parameters.

When developing UKHPI locally, the data API URL still needs to be passed via
the environment. For example:

```sh
API_SERVICE_URL="http://....." rails server
```

To prevent unauthorised access to the API, the data API on deployment servers
is protected so that it can only be accessed from `localhost`. Therefore, when
working on API a developer needs to map access to the API so that it appears
to be coming via localhost on the remote server. We can do this by creating
an ssh tunnel.

#### Setting up an ssh tunnel to access the data service

First, check that you have the right ssh config. You will need a copy of the
`lr.pem` key (available on S3, see the ops team for help getting access),
and the following configuration in `~/.ssh/config`:

```text
Host hmlr-*
    IdentityFile   ~/.ssh/lr.pem
    User           ec2-user
    HostName       %h.epimorphics.net
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host 10.10.10.* hmlr_*
  ProxyJump hmlr-bastion
  IdentityFile  ~/.ssh/lr.pem
  User ec2-user
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

Next we need to know the hostname of the service that's currently hosting the running
service in the `dev` environment. This will typically be a name like `hmlr-dev-pres_071`,
but the numerical suffix will change as the cluster is periodically updated by the ops
team. There are two ways (at least) that we can get this information:

- using [Sensu](https://sensu-hmlr.epimorphics.net/), using the **entities** tab, or
- using the AWS console, under EC2 instances.

In both cases, you will need credentials to log in to Sensu or AWS. See someone in the
infrastructure team if you need credentials but don't have them.

The remainder of this guide will assume `hmlr_dev_pres_071`, which is correct as of the
time of writing (but may not be by the time you are reading this!)

Check that you can access a server by directly connecting via ssh:

```sh
$ ssh hmlr_dev_pres_071
Warning: Permanently added 'hmlr-bastion.epimorphics.net' (ECDSA) to the list of known hosts.
**Warning**: this is a private system operated by Epimorphics Ltd
Warning: Permanently added 'hmlr_dev_pres_071' (ECDSA) to the list of known hosts.
**Warning**: this is a private system operated by Epimorphics Ltd
$
```

Assuming this succeeds, you can set up an ssh tunnel to map the port where the data
API is running on the remote machine to a convenient port on your computer. The local
port you choose is up to you, but a good choice is port 8080. The data service runs
on port 8081 on the remote service, so the tunnel command is:

```sh
$ ssh -f hmlr_dev_pres_071 -L 8080:localhost:8081 -N
```

If this succeeds, you should be able to see the open port with `lsof`:

```sh
$ lsof -i :8080
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
ssh     71358  ian    3u  IPv6 766085      0t0  TCP ip6-localhost:http-alt (LISTEN)
ssh     71358  ian    6u  IPv4 766086      0t0  TCP localhost:http-alt (LISTEN)
```

You can then use `localhost:8080` as the data service URL to give to the application
via the environment:

```sh
$ API_SERVICE_URL=http://localhost:8080 rails server
=> Booting Puma
=> Rails 6.1.3.2 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Puma version: 5.3.2 (ruby 2.6.6-p146) ("Sweetnighter")
*  Min threads: 5
*  Max threads: 5
*  Environment: development
*          PID: 72553
* Listening on http://127.0.0.1:3000
* Listening on http://[::1]:3000
Use Ctrl-C to stop
```

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