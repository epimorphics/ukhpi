# UK House Price Index (UKHPI) open data application

This is the repo for the application that presents UKHPI open data on behalf of
Land Registry (England and Wales), Registers of Scotland, Land and Property
Services (Northern Ireland) and the UK Office for National Statistics (ONS).

Development work was carried out by [Epimorphics
Ltd](http://www.epimorphics.com), funded by [HM Land
Registry](https://www.gov.uk/government/organisations/land-registry).

Code in this repository is open-source under the MIT license. The UKHPI data
itself is freely available under the terms of the [Open Government
License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

## Developer notes

### Installation dependencies

The app currently depends on Ruby version 2.6.x. The actual version is specified
in the `.ruby-version` file, which can be used with
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

### Local data service

The application communicates with the HMLR data API (which uses Sapi-NT) to
provide the data to be displayed. The actual API is specified by the environment
variable `API_SERVICE_URL`.

When developing UKHPI, it is necessary to have a dev instance of the API
available. Since, for operations reasons, the actual service URL is not exposed
to the open Internet, you will need to run a local instance of the service. This
follows the same pattern as [the PPD
app](https://github.com/epimorphics/ppd-explorer), as follows:

Developers can run a Docker container that defines the SapiNT API directly from
the AWS Docker registry. To do this, you will need:

- AWS IAM credentials to connect to the HMLR AWS account (see Dave or Andy)
- the ECR credentials helper installed locally (see
  [here](https://github.com/awslabs/amazon-ecr-credential-helper))
- Set the contents of your `~/.docker/config.json` file to be:

```sh
{
 "credsStore": "ecr-login"
}
```

This configures the Docker daemon to use the credential helper for all Amazon
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

With this set up, you should be able to run the container, mapped to
`localhost:8080` using:

```sh
$ AWS_PROFILE=hmlr \
docker run \
-e SERVER_DATASOURCE_ENDPOINT=https://hmlr-dev-pres.epimorphics.net/landregistry/sparql \
-p 8080:8080 \
018852084843.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/lr-data-api/dev:<LATEST_API_IMAGE_VERSION>
```

Note: the identity of the Docker image will change periodically. The currently
deployed dev api image version is given by the `api` tag in the ansible [dev
configuration](https://github.com/epimorphics/hmlr-ansible-deployment/blob/master/ansible/group_vars/dev/tags.yml#L2).

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

If you need to run a different API version then the easiest route to discovering
the most recent is to use the [AWS
ECR](https://eu-west-1.console.aws.amazon.com/ecr/repositories/private/018852084843/epimorphics/lr-data-api/dev?region=eu-west-1)
console or look at the hash to the relevant commit in
[lr-data-api](https://github.com/epimorphics/lr-data-api).

### Running the app locally in dev mode

Assuming the API is running on port 8080 (the default), to start the app locally:

```sh
API_SERVICE_URL=http://localhost:8080 rails server
```

And then visit [`localhost:3000`](http://localhost:3000/).

### Running the app locally as a Docker image

It can be useful to run the compiled Docker image, that will be run by the
production installation, locally yourself. Assuming you have the dev API
running on `localhost:8080` (the default), then you can run the Docker image
for the app itself as follows:

```sh
API_SERVICE_URL=http://host.docker.internal:8080 make run
```

Note that `host.docker.internal` is a special alias for `localhost`, which is
[supported by
Docker](https://medium.com/@TimvanBaarsen/how-to-connect-to-the-docker-host-from-inside-a-docker-container-112b4c71bc66).

Assuming the Docker container starts up OK, you will need a proxy to simulate
the effect of accessing the application via its ingress path
(`/app/ukhpi`). There is a [simple web
proxy](https://github.com/epimorphics/simple-web-proxy) that you can use.

With the simple web proxy, and the two Docker containers running, access the
application as
[`localhost:3001/app/ukhpi/`](http://localhost:3001/app/ukhpi/).

### Coding standards

`rubocop` should always return a clean status with no warnings.

### Tests

Once the API is started you can invoke the tests with the simple command below[^2]:

```sh
rake test
```

### Outline domain model

In the 2017 update, we're extending the display to present all of the underlying
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

### Rails script tasks

Some development tasks are handled by automated Rails task scripts. All tasks
code is in `./lib/tasks/*.rake`. You can list all of the tasks with `rails -T`.
The mostly commonly useful ones are:

- _`test`_\
  Run the test suite

- _`ukhpi:aspects`_\
  Generate a JavaScript description of the DSD aspects, as described by the
  `DataModel` class, which directly translates from the `UKHPI-dsd.ttl` file

- _boundaries tasks_\
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

## Deployment

The deployment process has been rewritten around a new set of standard
components, following local best practice. Specifically:

- a set of standardised GitHub actions, using shared workflow definitions, are
  used to orchestrate building and pushing Docker images under certain
  conditions (see below)
- Ansible is used to manage the orchestration of servers and services
- a `Makefile` is the key interface between the deployment automation and the
  application code, especially `make image` and `make tag`.

The determination of which Docker images go to which environments is managed by
the `deployment.yml` file. At the time of writing:

- tags matching `vNNN`, e.g. `v1.2.3` Images built from this tag will be
  deployed to production environments
- branch `dev-infrastructure` Images built from this branc will be deployed to
  the `dev` environment

### entrypoint.sh

This script is used as the main entry point for starting the app from the
`Dockerfile`.

The Rails Framework requires certain values to be set as a Global environment
variable when starting. To ensure the `APPLICATION_ROOT` is only set in
one place per application we have added this to the `entrypoint.sh` file along
with the `SCRIPT_NAME`. The Rails secret is also created here.

There is a workaround to removing the PID lock of the Rails process in the event
of the application crashing and not releasing the process.

We have to pass the `API_SERVICE_URL` so that it is available in the
`entrypoint.sh` or the application will throw an error and exit before starting

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

## Other tasks

### Updating geographies

Many years, the boundaries of UK local authorities change. Sometimes mutliple
adjacent authorities merge to for a new unitary authority, or sometimes a
unitary authority is split off from an existing LA (e.g. City of Plymouth). In
this case, we need to update two data sources with the application, and
coordinate this change with HMLR (and, by extension, ONS)

In 2020, we updated the app due to various changes in LA boundaries, including
the creation of the Bournemouth, Christchurch and Poole UA. The timeline of
these changes was fairly typical, so I'm documenting it here for future
reference:

- April 2019: new boundaries go into effect
- Feb 2020: ONS perform their (single) yearly update of location tables
- March 2020: HMLR provided Epimorphics with a collection of test data,
  including the new regions table, as Turtle (`.ttl`) files
- March 2020: we loaded the test data into a dev server, in order to re-run the
  `rails ukhpi:locations` task. This updates the cached Ruby and Javascript
  locations tables, to save the application having to query the API every time a
  location is referred to
- In order to update the map UI in UKHPI, we need to regenerate the
  `ONS-Geographies` GeoJSON file. [Alex](mailto:alex.coley@epimorphics.com) has
  an FME script on his system that automates this. The basic process is: find
  and download the relevant shapefile from the ONS geographies portal, then run
  the script to convert the shapefile GeoJSON, simplifying the outlines along
  the way. We need to simplify the outlines, because otherwise the generated
  GeoJSON file is enormous. Doing the simplification in FME means that there are
  no gaps between adjacent authorities as the outlines are compressed. Once the
  initial GeoJSON file is produced, there is a simple shellscript to regularise
  the property names in the GeoJSON. See `bin/ons-geojson-cleanup`. The core
  issue is that the application code expects the GSS code for a location to be
  `code` and the location name to be `name`. In the ONS shapefile, the GSS code
  can be, for example, `rgn18cd` and the name `rgn18nm`. Rather than have the
  code adapt to these (I'm assuming they may change each year), it was easier to
  have a data-cleansing task. It could have been a rake task, but there are some
  Linux command utilities that do the job very easily. The code will need to be
  changed to reference the new GeoJSON file, i.e.
  `app/javascript/data/ONS-Geographies-$YEAR.json`.
- Finally, the application is published on `dev` for the Plymouth team to test.

## Configuration environment variables

We use a number of environment variables to determine the runtime behaviour of
the application:

| name                       | description                                                          | typical value           |
| -------------------------- | -------------------------------------------------------------------- | ----------------------- |
| `APPLICATION_ROOT`         | The path from the server root to the application                     | `/app/ukhpi`            |
| `API_SERVICE_URL`          | The base URL from which data is accessed, including the HTTP scheme  | `http://localhost:8080` |
| `SENTRY_API_KEY`           | The DSN for reporting errors and other events to Sentry              |                         |

[^1]: With Docker 1.13.0 or greater, you can configure Docker to use different
credential helpers for different registries.

[^2]: You may need to preface the `rake test` command with `bundle exec` if you
      are using a Ruby version manager such as `rbenv` or `rvm`.
