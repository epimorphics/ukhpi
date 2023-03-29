# UK House Price Index (UKHPI) open data application

This is the repo for the application that presents UKHPI open data on behalf
of Land Registry (England and Wales), Registers of Scotland, Land and Property
Services (Northern Ireland) and the UK Office for National Statistics (ONS).

Development work was carried out by [Epimorphics Ltd](http://www.epimorphics.com),
funded by [HM Land Registry](https://www.gov.uk/government/organisations/land-registry).

Code in this repository is open-source under the MIT license. The UKHPI data
itself is freely available under the terms of the
[Open Government License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

## Running this service

### Production mode

When deployed applications will run behind a reverse proxy.

This enables request to be routed to the appropriate application base on the request path.
In order to simplifiy the proxy configuration we retain the original path where possible.

Thus applications running in `production` mode will do so from a sub-directory i.e `/app/ukhpi`.

It is expected that any rails application running in `production` mode will set
the `config.relative_url_root` property to this sub-directory within the file
`config/environments/production.rb`.

If need be, `config.relative_url_root` may by overridden by means of the
`RAILS_RELATIVE_URL_ROOT` environment variable, althought this could also
require rebuilding the assets or docker image.

If running more than one application locally ensure that each is listerning on a
separate port. In the case of running local docker images, the required
configuration is captured in the `Makefile` and an image can be run by using

```sh
make image run
```

or, if the image is already built, simply

```sh
make run
```

For rails applications you can start the server locally using the following command:

```sh
rails server -e production -p <port> -b 0.0.0.0
```

To test the running application visit `localhost:<port>/{application path}`.

For information on how to running a proxy to mimic production and run multple services
together see [simple-web-proxy](https://github.com/epimorphics/simple-web-proxy/edit/main/README.md)

## Runtime Configuration environment variables

We use a number of environment variables to determine the runtime behaviour
of the application:

| name                       | description                                                             | default value              |
| -------------------------- | ----------------------------------------------------------------------- | -------------------------- |
| `API_SERVICE_URL`          | The base URL from which data is accessed, including the HTTP scheme eg. | None                       |
|                            | http://localhost:8888 if running a `data-api service` locally           |                            |
|                            | http://data-api:8080  if running a `data-api docker` image locally      |                            |
| `SENTRY_API_KEY`           | The DSN for sending reports to the PPD Sentry account                   | None                       |


### Running the Data API during locally

The application connects to the triple store via a `data-api` service.

The easiest way to do this is as a local docker container. The image can be built from [lr-data-api repository](https://github.com/epimorphics/lr-data-api).
or pulled from Amazon Elastic Container Registry [ECR](https://eu-west-1.console.aws.amazon.com/ecr/repositories/private/018852084843/epimorphics/lr-data-api/dev?region=eu-west-1)

#### Building and running from [lr-data-api repository](https://github.com/epimorphics/lr-data-api)

To build and a run a new docker image check out the [lr-data-api repository](https://github.com/epimorphics/lr-data-api) and run
```sh
make image run
```

#### Running an existing [ECR](https://eu-west-1.console.aws.amazon.com/ecr/repositories/private/018852084843/epimorphics/lr-data-api/dev?region=eu-west-1) image

Obtaining an ECR image requires:

- AWS IAM credentials to connect to the HMLR AWS account
- the ECR credentials helper installed locally (see [here](https://github.com/awslabs/amazon-ecr-credential-helper))
- this line: `"credsStore": "ecr-login"` in `~/.docker/config.json`

Once you have a local copy of you required image, it is advisable to run a local docker bridge network to mirror 
production and development environments.

Running a client application as a docker image from their respective `Makefile`s will set this up 
automatically, but to confirn run

```sh
docker network inspect dnet
```

To create the docker network run
```sh
docker network create dnet
```

To run the Data API as a docker container:

```sh
docker run --network dnet -p 8888:8080 --rm --name data-api \
    -e SERVER_DATASOURCE_ENDPOINT=https://landregistry.data.gov.uk/landregistry/query \
    018852084843.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/lr-data-api/dev:1.0-SNAPSHOT_a5590d2
```
the latest image can be found here [dev](https://github.com/epimorphics/hmlr-ansible-deployment/blob/master/ansible/group_vars/dev/tags.yml) 
and [production](https://github.com/epimorphics/hmlr-ansible-deployment/blob/master/ansible/group_vars/prod/tags.yml).

The full list of versions can be found at [AWS
ECR](https://eu-west-1.console.aws.amazon.com/ecr/repositories/private/018852084843/epimorphics/lr-data-api/dev?region=eu-west-1)

Note: port 8080 should be avoided to allow for a reverse proxy to run on this port.

With this set up, the api service is available on `http://localhost:8888` from the host or `http://data-api:8080`
from inside other docker containers.


## Developer notes

### Installation dependencies

The app currently depends on Ruby version 2.6.x. The actual version is
specified in the `.ruby-version` file, which can be used with
[rbenv](https://github.com/rbenv/rbenv) to install the appropriate version
locally. The `.ruby-version` file will also determine the version of Ruby that
will be installed in the Docker image as part of the automated build and deploy
process.

To install on dev machine:

```sh
git clone git@github.com:epimorphics/ukhpi.git
cd ukhpi
bundle install
yarn install
```

### Coding standards

`rubocop` should always return a clean status with no warnings.

### Tests

To run the tests:

```sh
rails test
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

- *`test`*\
  Run the test suite

- *`ukhpi:aspects`*\
  Generate a JavaScript description of the DSD aspects, as described by the
  `DataModel` class, which directly translates from the `UKHPI-dsd.ttl` file

- *boundaries tasks*\
  A number of tasks releated to generating simplified GeoJSON files from the Shapefiles downloaded
  from ONS. These tasks will need to be re-run when the boundaries change,
  e.g. when local authorities are merged or split to form new unitary authorities.
  See below for more details.

- *`ukhpi:describe[uri]`*\
  A convenient way to perform a SPARQL describe for the given URI

- *`ukhpi:locations`*\
  This task uses a SPARQL query to list all of the geographical regions in the UKHPI
  data, and their containment hierarchy, and generate cached versions of that data as
  code. In particular, it regenerates `app/javascript/data/locations-data.js` and
  `app/models/locations_table.rb`. This task should be re-run if and when the regions
  data from LR is changed in the triple store.

Note that, by default, SPARQL queries will be run against the dev triple store.
To direct the query against a different SPARQL endpoint, change the `SERVER` environment
variable:

```sh
SERVER="https://lr-dev.epimorphics.net/landregistry/query" rails ukhpi:locations
```

### Prometheus monitoring

[Prometheus](https://prometheus.io) is set up to provide metrics on the
`/metrics` endpoint. The following metrics are recorded:

- `api_status` (counter)
  Response from data API, labelled by response status code
- `api_requests` (counter)
  Count of requests to the data API, labelled by result success/failure
- `api_connection_failure` (counter)
  Could not connect to back-end data API, labelled by message
- `api_service_exception` (counter)
  The response from the back-end data API was not processed, labelled by message
- `internal_application_error` (counter)
  Unexpected events and internal error count, labelled by message
- `memory_used_mb` (gauge)
  Process memory usage in megabytes
- `api_response_times` (histogram)
  Histogram of response times of successful API calls.

Internally, we use ActiveSupport Notifications to emit events which are
monitored and collected by the Prometheus store. Relevant pieces of the
app include:

- `config/initializers/prometheus.rb`
  Defines the Prometheus counters that the app knows about, and registers them
  in the metrics store (see above)
- `config/initializers/load_notification_subscribers.rb`
  Some boiler-plate code to ensure that all of the notification subscribers
  are loaded when the app starts
- `app/subscribers`
  Folder where the subscribers to the known ActiveSupport notifications are
  defined. This is where the transform from `ActiveSupport::Notification` to
  Prometheus counter or gauge is performed.

In addition to the metrics we define, there is a collection of standard
metrics provided automatically by the
[Ruby Prometheus client](https://github.com/prometheus/client_ruby)

To test Prometheus when developing locally, there needs to be a Prometheus
server running. Tip for Linux users: do not install the Prometheus apt
package. This starts a locally running daemon with a pre-defined
configuration, which is useful when monitoring the machine on which the
server is running. A better approach for testing Prometheus is to
[download](https://prometheus.io/download/) the server package and
run it locally, with a suitable configuration. A basic config for
monitoring a Rails application is provided in `test/prometheus/dev.yml`.

Using this approach, and assuming you install your local copy of
Prometheus into `~/apps`, a starting command line would be something like:

```sh
~/apps/prometheus/prometheus-2.32.1.linux-amd64/prometheus \
  --config.file=test/prometheus/dev.yml \
  --storage.tsdb.path=./tmp/metrics2
```

Something roughly equivalent should be possible on Windows and Mac as well.

## Other tasks

### Updating geographies

Many years, the boundaries of UK local authorities change. Sometimes mutliple adjacent
authorities merge to for a new unitary authority, or sometimes a unitary authority
is split off from an existing LA (e.g. City of Plymouth). In this case, we need to
update two data sources with the application, and coordinate this change with HMLR
(and, by extension, ONS)

In 2020, we updated the app due to various changes in LA boundaries, including the
creation of the Bournemouth, Christchurch and Poole UA. The timeline of these changes
was fairly typical, so I'm documenting it here for future reference:

- April 2019: new boundaries go into effect
- Feb 2020: ONS perform their (single) yearly update of location tables
- March 2020: HMLR provided Epimorphics with a collection of test data, including
  the new regions table, as Turtle (`.ttl`) files
- March 2020: we loaded the test data into a dev server, in order to re-run
  the `rails ukhpi:locations` task. This updates the cached Ruby and Javascript
  locations tables, to save the application having to query the API every time
  a location is referred to
- In order to update the map UI in UKHPI, we need to regenerate the `ONS-Geographies`
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
- Finally, the application is published on `dev` for the Plymouth team to test.
