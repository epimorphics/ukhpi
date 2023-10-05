# UK House Price Index (UKHPI) open data application

This is the repo for the application that presents UKHPI open data on behalf of
Land Registry (England and Wales), Registers of Scotland, Land and Property
Services (Northern Ireland) and the UK Office for National Statistics (ONS).

Please see the other repositories in the [HM Land Registry Open
Data](https://github.com/epimorphics/hmlr-linked-data/) project for more
details.

Development work was carried out by [Epimorphics
Ltd](http://www.epimorphics.com), funded by [HM Land
Registry](https://www.gov.uk/government/organisations/land-registry).

Code in this repository is open-source under the MIT license. The UKHPI data
itself is freely available under the terms of the [Open Government
License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

## Installing dependencies

The app currently depends on Ruby version 2.6.x. The actual version is specified
in the `.ruby-version` file, which can be used with
[rbenv](https://github.com/rbenv/rbenv) to install the appropriate version
locally. The `.ruby-version` file will also determine the version of Ruby that
will be installed in the Docker image as part of the automated build and deploy
process.

To install on the dev machine:

```sh
git clone git@github.com:epimorphics/ukhpi.git
cd ukhpi
bundle install
yarn install
```

## Running the data API locally

### Prerequisites

The application communicates with the HMLR data API (which uses Sapi-NT) to
provide the data to be displayed. The actual API location is specified by the
environment variable `API_SERVICE_URL`.

When developing UKHPI locally, it is necessary to have a dev instance of the API
available. Since, for operations reasons, the actual service URL is not exposed
to the open internet, you will need to run a local instance of the service.

This follows the same pattern as [the PPD
app](https://github.com/epimorphics/ppd-explorer), and developers can run a
Docker container that defines the SapiNT API directly from the AWS Docker
registry. To do this, you will need:

- AWS IAM credentials to connect to the HMLR AWS account
- the ECR credentials helper installed locally (see
  [here](https://github.com/awslabs/amazon-ecr-credential-helper))
- Setting the contents of your `{HOME}/.docker/config.json` file to be:

```sh
{
 "credsStore": "ecr-login"
}
```

This configures the Docker daemon to use the credential helper for _all_ Amazon
ECR registries.

To use a credential helper for a specific ECR registry[^1], create a
`credHelpers` section with the URI of your ECR registry:

```sh
{
  [...]
  "credHelpers": {
    "public.ecr.aws": "ecr-login",
    "018852084843.dkr.ecr.eu-west-1.amazonaws.com": "ecr-login"
  }
}
```

The local application can then connect to the triple store via the `data-api`
service.

### Running the API

The easiest way to do this is via a local docker container. The `data-api` image
can be built from [lr-data-api
repository](https://github.com/epimorphics/lr-data-api). or pulled from Amazon
Elastic Container Registry
[ECR](https://eu-west-1.console.aws.amazon.com/ecr/repositories/private/018852084843/epimorphics/lr-data-api/dev?region=eu-west-1)

Once you have a local copy of the required `data-api` image, to run the Data API
as a docker container:

```sh
docker run --network dnet -p 8888:8080 --rm --name data-api \
    -e SERVER_DATASOURCE_ENDPOINT=https://landregistry.data.gov.uk/landregistry/query \
    018852084843.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/lr-data-api/dev:1.0-SNAPSHOT_a5590d2
```

Which then should produce something like:

```text
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.2.0.RELEASE)

{"ts":"2022-03-21T16:12:26.585Z","version":"1","logger_name":"com.epimorphics.SapiNtApplicationKt",
"thread_name":"main","level":"INFO","level_value":20000,
"message":"No active profile set, falling back to default profiles: default"}
```

The latest images can be found here for
[dev](https://github.com/epimorphics/hmlr-ansible-deployment/blob/master/ansible/group_vars/dev/tags.yml)
and
[production](https://github.com/epimorphics/hmlr-ansible-deployment/blob/master/ansible/group_vars/prod/tags.yml).

The identity of the Docker image will change periodically so the full list of
versions can be found at [AWS
ECR](https://eu-west-1.console.aws.amazon.com/ecr/repositories/private/018852084843/epimorphics/lr-data-api/dev?region=eu-west-1)

N.B. Port 8080 should be avoided to allow for a reverse proxy to run on this
port.

With this set up, the api service is available on `http://localhost:8888` from
the host or `http://data-api:8080` from inside other docker containers.

Note: It is advisable to run a local docker bridge network to mirror production
and development environments.

Running an HMLR application as a docker image from the respective `Makefile`
will set up the local docker bridge network automatically, but to confirm this
run:

```sh
docker network inspect dnet
```

If needed, to create the docker network run:

```sh
docker network create dnet
```

## Running the app

### Locally

Assuming the `Data API` is running on `http://localhost:8888` (the default), to
start the app locally:

```sh
API_SERVICE_URL=http://localhost:8888 RAILS_ENV=<environment> make server
```

And then visit <http://localhost:3002>

or, to start within a sub-directory, use the following command:

```sh
API_SERVICE_URL=http://localhost:8888 RAILS_ENV=<environment> RAILS_RELATIVE_URL_ROOT=/app/ukhpi make server
```

And then visit <http://localhost:3002/app/ukhpi>.

N.B. The default for `RAILS_ENV` is `production` if omitted.

### As a Docker image

It can be useful to check the compiled Docker image, that will be run by the
production installation, locally yourself. Assuming you have the `Data API`
running in docker, then you can build and run the Docker image for the app
itself as follows:

```sh
make image run
```

or, if the image is already built, simply:

```sh
make run
```

You will be able to follow the progress of the invocation in the terminal:

```sh
make run
Starting ukhpi ...
Using docker network dnet
{"ts":"2022-03-21T11:12:27.340Z","level":"INFO","message":"API_SERVICE_URL=http://data-api:8080"}
{"ts":"2022-03-21T11:12:34.970Z","level":"INFO","message":"exec ./bin/rails server -e production -b 0.0.0.0"}
```

Assuming the Docker container starts up OK, you can again access the application
at <http://localhost:3002/app/ukhpi/>

N.B. In `production` mode, `SECRET_KEY_BASE` is also required. It is insufficient to
just set this as the value must be exported _**before**_ running the commands
above. i.e.

```sh
export SECRET_KEY_BASE=$(./bin/rails secret)
```

### Development and Production mode differences

Applications running in `development` mode default to not use a sub-directory to
aid stand-alone development.

Applications running in `production` mode default to use a sub-directory, i.e
`/app/ukhpi`.

In each case, this is achieved by assigning the `config.relative_url_root`
property to the appropriate "root" set within the respective environment file:
`config/environments/(development|production).rb`.

If need be, `config.relative_url_root` may by overridden by means of the
`RAILS_RELATIVE_URL_ROOT` environment variable, althought this could also
require rebuilding the assets or docker image when running inside docker.

### Running the complete HMLR suite locally

Then entire HLMR suite of applications can be run locally as individual rails
servers in `development` mode as noted
[above](#running-the-app-locally); however, when deployed, the HMLR
applications will be docker images and run behind a reverse proxy to route to
the appropriate application based on the request path.

In order to simplifiy the proxy configuration we retain the original path where
possible.

For running a proxy to mimic production and join multple services together see
the information found in the
[simple-web-proxy](https://github.com/epimorphics/simple-web-proxy/edit/main/README.md)
repository.

## Updating geographies

Over many years, the boundaries of UK Local Authorities (LA) change. Sometimes
multiple adjacent authorities merge to for a new unitary authority (UA), or
sometimes a unitary authority is split off from an existing LA (e.g. City of
Plymouth).

In this case, we need to update two data sources within the application, and
coordinate this change with HMLR (and, by extension, ONS).

For example, in 2020 we updated the app due to various changes in LA boundaries,
including the creation of the Bournemouth, Christchurch and Poole UA. The
timeline of these changes was fairly typical, so we've documented it here for
future reference:

- April 2019: new boundaries go into effect.
- Feb 2020: ONS perform their (single) yearly update of location tables.
- March 2020: HMLR provided Epimorphics with a collection of test data,
  including the new regions table, as Turtle (`.ttl`) files.
- March 2020: we loaded the test data into a dev server in order to re-run the
  [`rails ukhpi:locations` task](#rails-script-tasks). This task updates the
  cached Ruby and Javascript locations tables, to save the application having to
  query the API every time a location is referred to.
- In order to update the map UI in UKHPI, we need to regenerate the
  `ONS-Geographies` GeoJSON file. [Alex](mailto:alex.coley@epimorphics.com) has
  a Feature Migration Engine (FME) script on his system that automates this.

  We need to simplify the outlines, because otherwise the generated GeoJSON file
  is enormous. Doing the simplification in FME means that there are no gaps
  between adjacent authorities as the outlines are compressed.

  The basic process is:

    1. Find and download the relevant shapefile from the ONS geographies portal.
    2. Run the FME script to convert the shapefile GeoJSON, simplifying the
    outlines along the way.
    3. Once the initial GeoJSON file is produced, there is a simple shellscript
  to regularise the property names in the GeoJSON, see
  `bin/ons-geojson-cleanup`.

  The core issue is that the application code expects the GSS code for a
  location to be `code` and the location name to be `name`. In the ONS
  shapefile, the GSS code can be, for example, `rgn18cd` and the name `rgn18nm`.

  Rather than have the code adapt to these, assuming they may change each year,
  it was easier to have a data-cleansing task. It could have been a rake task,
  but there are some Linux command utilities that do the job very easily. The
  code will need to be changed to reference the new GeoJSON file, i.e.
  `app/javascript/data/ONS-Geographies-$YEAR.json`.

- Finally, the application is published on
  <https://hmlr-dev-pres.epimorphics.net/app/ukhpi/> for the Plymouth team to
  test.

## Outline domain model

In the 2017 update, we extended the display to present all of the underlying
statistics calculated by ONS. In addition to the figures by property type (all,
detached houses, semi-detached, terraced and flat/maisonette), there are also
figures for property status (new build vs. existing), buyer status (first-time
buyer or not), and funding status (paid cash or bought with a mortgage).  For
each of these figures, multiple indicators are calculated: the statistical
index, the percentage change (monthly and annual) and the average price. For
some of the statistics, a sales volume indicator is also available.

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

### Coding standards

`rubocop` should always return a clean status with no warnings.

### Tests

Once the API is started you can invoke the tests with the simple command
below[^2]:

```sh
rake test
```

### Runtime Configuration environment variables

A number of environment variables to determine the runtime behaviour of the
application:

| name                       | description                                                             | default value              |
| -------------------------- | ----------------------------------------------------------------------- | -------------------------- |
| `API_SERVICE_URL`          | The base URL from which data is accessed, including the HTTP scheme eg. | None                       |
|                            | <http://localhost:8888> if running a `data-api` service locally           |                            |
|                            | <http://data-api:8080>  if running a `data-api` docker image locally      |                            |
| `SECRET_KEY_BASE`          | See [description](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base).| |
|                            | For `development` mode a acceptable value is already configured; in production mode, this should be set to the output of `rails secret`.||
|                            | This is handled automatically when starting a docker container, or the `server` `make` target | |
| `SENTRY_API_KEY`           | The Data Source Name (DSN) for sending reports to the Sentry account                   | None                       |

### Issues

Please add issues to the [shared issues
list](https://github.com/epimorphics/hmlr-linked-data/issues)

### Deployment

The detailed deployment mapping is described in `deployment.yml`. At the time
of writing, using the new infrastructure, the deployment process is as follows:

- commits to the `dev-infrastructure` branch will deploy the dev server
- commits to the `preprod` branch will deploy the pre-production server
- any commit on the `prod` branch will deploy the production server as a new
  release

If the commit is a "new" release, the deployment should be tagged with the same
semantic version number matching the  `BREAKING.FEATURE.PATCH` format, e.g.
`v1.2.3`, the same as should be set in the `/app/lib/version.rb`; also, a short
annotation summarising the updates should be included in the tag as well.

Once the production deployment has been completed and verified, please create a
release on the repository using the same semantic version number. Utilise the
`Generate release notes from commit log` option to create specific notes on the
contained changes as well as the ability to diff agains the previous version.

#### `entrypoint.sh` features

- Workaround to removing the PID lock of the Rails process in the event of the
  application crashing and not releasing the process.
- Guards to ensure the required environment variables are set accordingly and
  trigger the build to fail noisily and log to the system.
- Rails secret creation for `SECRET_KEY_BASE` assignment; see [Runtime
  Configuration environment
  variables](#runtime-configuration-environment-variables).

### Rails script tasks

Some development tasks are handled by automated Rails task scripts. All tasks
code is in `./lib/tasks/*.rake`. You can list all of the tasks with `rails -T`.
The mostly commonly useful ones are:

- _`test`_\
  Run the test suite

- _`ukhpi:aspects`_\
  Generate a JavaScript description of the DSD aspects, as described by the
  `DataModel` class, which directly translates from the `UKHPI-dsd.ttl` file

- **boundaries tasks**\
  A number of tasks releated to generating simplified GeoJSON files from the
  Shapefiles downloaded from ONS. These tasks will need to be re-run when the
  boundaries change, e.g. when local authorities are merged or split to form new
  unitary authorities. See below for more details.

  - _`ukhpi:describe[uri]`_\
  A convenient way to perform a SPARQL describe for the given URI

  - _`ukhpi:locations`_\
  This task uses a SPARQL query to list all of the geographical regions in the
  UKHPI data, and their containment hierarchy, and generate cached versions of
  that data as code. In particular, it regenerates
  `app/javascript/data/locations-data.js` and   `app/models/locations_table.rb`.
  This task should be re-run if and when the regions data from LR is changed in
  the triple store.

Note that, by default, SPARQL queries will be run against the dev triple store.
To direct the query against a different SPARQL endpoint, change the `SERVER`
environment variable:

```sh
SERVER="https://lr-dev.epimorphics.net/landregistry/query" rails ukhpi:locations
```

### Prometheus monitoring

[Prometheus](https://prometheus.io) is set up to provide metrics on the
`/metrics` endpoint. The following metrics are recorded:

- `api_status` (counter) Response from data API, labelled by response status
  code
- `api_requests` (counter) Count of requests to the data API, labelled by result
  success/failure
- `api_connection_failure` (counter) Could not connect to back-end data API,
  labelled by message
- `api_service_exception` (counter) The response from the back-end data API was
  not processed, labelled by message
- `internal_application_error` (counter) Unexpected events and internal error
  count, labelled by message
- `memory_used_mb` (gauge) Process memory usage in megabytes
- `api_response_times` (histogram) Histogram of response times of successful API
  calls.

Internally, we use ActiveSupport Notifications to emit events which are
monitored and collected by the Prometheus store. Relevant pieces of the app
include:

- `config/initializers/prometheus.rb` Defines the Prometheus counters that the
  app knows about, and registers them in the metrics store (see above)
- `config/initializers/load_notification_subscribers.rb` Some boiler-plate code
  to ensure that all of the notification subscribers are loaded when the app
  starts
- `app/subscribers` Folder where the subscribers to the known ActiveSupport
  notifications are defined. This is where the transform from
  `ActiveSupport::Notification` to Prometheus counter or gauge is performed.

In addition to the metrics we define, there is a collection of standard metrics
provided automatically by the [Ruby Prometheus
client](https://github.com/prometheus/client_ruby)

To test Prometheus when developing locally, there needs to be a Prometheus
server running. Tip for Linux users: do not install the Prometheus apt package.
This starts a locally running daemon with a pre-defined configuration, which is
useful when monitoring the machine on which the server is running. A better
approach for testing Prometheus is to
[download](https://prometheus.io/download/) the server package and run it
locally, with a suitable configuration. A basic config for monitoring a Rails
application is provided in `test/prometheus/dev.yml`.

Using this approach, and assuming you install your local copy of Prometheus into
`~/apps`, a starting command line would be something like:

```sh
~/apps/prometheus/prometheus-2.32.1.linux-amd64/prometheus \
  --config.file=test/prometheus/dev.yml \
  --storage.tsdb.path=./tmp/metrics2
```

Something roughly equivalent should be possible on Windows and Mac as well.

[^1]: With Docker 1.13.0 or greater, you can configure Docker to use different
credential helpers for different registries.

[^2]: You may need to preface the `rake test` command with `bundle exec` if you
      are using a Ruby version manager such as `rbenv` or `rvm`.
