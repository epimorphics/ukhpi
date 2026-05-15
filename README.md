# UK House Price Index (UKHPI) open data application

This is a web application that presents UK House Price Index open data, allowing
users to browse, compare, and download UKHPI statistics by geography, property
type, and time period. It is published on behalf of Land Registry (England and
Wales), Registers of Scotland, Land and Property Services (Northern Ireland) and
the UK Office for National Statistics (ONS).

Please see the other repositories in the [HM Land Registry Open
Data](https://github.com/epimorphics/hmlr-linked-data/) project for more
details.

Development work was carried out by [Epimorphics
Ltd](http://www.epimorphics.com), funded by [HM Land
Registry](https://www.gov.uk/government/organisations/land-registry).

Code in this repository is open-source under the MIT license. The UKHPI data
itself is freely available under the terms of the [Open Government
License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

For more information about this project visit [the
wiki](https://github.com/epimorphics/ukhpi/wiki).

## Tech stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8, served via Puma |
| Frontend | Vue 2 SPA, bundled via Vite Rails |
| Data | SPARQL endpoint queried via the `data_services_api` gem |
| Maps | Leaflet |
| Charts | D3 (v1–v3 modules) |
| UI components | Element UI |
| Internationalisation | Vue I18n (English / Welsh) |
| Error tracking | Sentry |
| CSS | Sass + PostCSS + GOV.UK Frontend |

The Rails layer handles routing and data fetching; the Vue layer owns the UI,
state (Vuex), and client-side routing (Vue Router).

## Developer setup

### 1. Install Ruby

Use [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com) to
install the version pinned in `.ruby-version` (currently `3.4.9`).

With rbenv:

```bash
rbenv install        # reads .ruby-version automatically
gem install bundler
```

### 2. Install Node

Use [nvm](https://github.com/nvm-sh/nvm) to install the version pinned in
`.nvmrc` (currently `24`):

```bash
nvm install          # reads .nvmrc automatically
nvm use
```

### 3. Enable Yarn

Yarn 4 is managed via Corepack, which ships with Node:

```bash
corepack enable
corepack prepare     # installs the exact version declared in package.json
```

### 4. Authenticate with the private gem registry

The `data_services_api` and `json_rails_logger` gems are hosted on the
Epimorphics GitHub Package Registry. You need a GitHub Personal Access Token
with the `read:packages` scope.

Configure Bundler with your token:

```bash
./bin/bundle config set --local rubygems.pkg.github.com epimorphics:<your-token>
```

### 5. Install dependencies

```bash
./bin/bundle install   # Ruby gems
yarn install           # Node modules
```

### 6. Environment variables

`.env.development` contains sensible defaults for local development and is
checked in — no copying required. The app will start without any further
configuration.

If you need to override a value (e.g. point at a different API), create
`.env.local` alongside it — foreman loads both and `.env.local` takes
precedence. `.env.local` is gitignored.

| Variable | Default | Purpose |
|---|---|---|
| `API_SERVICE_URL` | `http://localhost:8888` | Backing SPARQL/data API |
| `PORT` | `3002` | Rails server port |
| `RAILS_ENV` | `development` | Rails environment |
| `LOG_LEVEL` | `debug` | Log verbosity |
| `SENTRY_ENABLED` | `false` | Enable Sentry error tracking |
| `SENTRY_AUTH_TOKEN` | — | Required only for production builds (source map upload) |
| `SENTRY_API_KEY` | — | Required only if `SENTRY_ENABLED=true` |

Vite exposes any variable prefixed with `VITE_`, `RAILS_`, `HMLR_`, `LOG_`,
or `SENTRY_` to the browser bundle.

## Data API

The app queries a backing data API at `API_SERVICE_URL` (default
`http://localhost:8888`). To run it locally, install Maven and follow the
instructions in the
[lr-data-api](https://github.com/epimorphics/lr-data-api) repository, ensuring
it listens on port `8888`.

## Running locally

```bash
bin/dev
```

This starts the Rails server and Vite dev server together. The app is served on
port 3002 by default, using the defaults in `.env.development`.

To override environment variables, pass your env file(s) explicitly:

```bash
bin/dev -e .env.local,.env.development
```

`.env.local` is gitignored — put local overrides there. Files listed later take
lower precedence, so `.env.development` acts as the fallback.

To use the debugger, start foreman without the web process and run Rails
separately:

```bash
foreman start -f Procfile.dev -e .env.development web=0,all=1
./bin/rails server -p 3002 -b 0.0.0.0
```

## Testing

```bash
./bin/spring stop      # avoid stale Spring state
./bin/rails test
```

Tests use VCR cassettes under `test/vcr_cassettes/`. To discard cassettes and
force live HTTP calls on the next run:

```bash
rm test/vcr_cassettes/*
```

To rebuild Vite assets before running tests:

```bash
./bin/vite build --clobber --mode=test
./bin/rails test
```

View the coverage report after a test run:

```bash
open coverage/index.html
```

## Linting

```bash
./bin/bundle exec rubocop -a          # Ruby — auto-corrects safe offences
yarn lint:fix                         # JS / TS / Vue — ESLint with auto-fix
./bin/bundle exec haml-lint app/      # HAML templates
```

## Generating location files

The location files are generated from the UKHPI data using the
`lib/tasks/location.rake` script. This script reads the UKHPI data from the
`SERVER` env var and generates the following updated location files:

- `app/models/locations_table.rb`
- `app/javascript/data/locations_data.js`

To generate the location files, run the following command:

```bash
SERVER=https://landregistry.data.gov.uk/app/ukhpi ./bin/rails ukhpi:locations
```

**Note:** The `SERVER` env var should point to the appropriate SPARQL endpoint.
Please verify the endpoint before running the command.

Further details on the generation of location files can be found in the
[wiki](https://github.com/epimorphics/ukhpi/wiki/Updating-geographies).

## Building and publishing

The `Makefile` is scoped to the Docker image build and publish pipeline.

```bash
make image     # Build the Docker image (requires .github-token)
make publish   # Tag and push to AWS ECR
make vars      # Print all build variables
make tag       # Print the computed image tag
make version   # Print the application version
```

Variables can be overridden on the command line, e.g.:

```bash
STAGE=preprod make publish
```

Branch-to-environment mapping is defined in `deployment.yaml`. CI runs
`publish` and `deploy` automatically on push via
`.github/workflows/publish-deploy.yml`.

## Releasing

This repository uses long-lived environment branches (`preprod`, `prod`) that are kept
as strict fast-forward pointers to tagged commits on `dev`. CI deploys automatically on
push, so promoting an environment is a case of fast-forwarding its branch and pushing.

**Key invariant:** environment branches always point to a tagged commit on `dev`'s
linear history. Direct pushes to environment branches are not permitted.

### Standard release

**1. Finish work on `dev`**

Merge all feature branches into `dev` and ensure CI passes.

**2. Bump the version and update the changelog**

Edit `app/lib/version.rb` and `CHANGELOG.md`, then commit and push to `dev`:

```bash
git add app/lib/version.rb CHANGELOG.md
git commit -m "chore: release vx.y.z"
git push origin dev
```

**3. Tag the release commit**

```bash
git tag vx.y.z
git push origin vx.y.z
```

**4. Promote each environment branch in turn**

Fast-forward `preprod` first, verify the deployment, then repeat for `prod`:

```bash
git checkout preprod
git merge --ff-only vx.y.z
git push origin preprod
```

CI will trigger automatically on push. Verify the deployment before promoting the next
environment. If `--ff-only` is refused, the branch has diverged — investigate before
proceeding.

```bash
git checkout prod
git merge --ff-only vx.y.z
git push origin prod
```

**5. Optionally create a GitHub release**

Go to **Releases** on the repository page, draft a new release from the tag, and
publish. GitHub's *Generate release notes* will draft notes from merged PR titles.

---

### Hotfix release

Use this when a critical fix must reach production before in-progress `dev` work is
ready to ship.

**1. Branch off the current production tag**

```bash
git checkout -b hotfix/vx.y.z vx.y.(z-1)
```

**2. Make the fix, tag it, and push**

```bash
git add <files>
git commit -m "fix: <description>"
git tag vx.y.z
git push origin hotfix/vx.y.z vx.y.z
```

**3. Bring the fix into `dev`**

The fix must land on `dev` before any environment is promoted.

Preferred — rebase (clean linear history):

```bash
git rebase hotfix/vx.y.z dev
git push --force-with-lease origin dev
```

Safe fallback — cherry-pick (no history rewrite):

```bash
git checkout dev
git cherry-pick vx.y.z
git push origin dev
```

If cherry-picking, tag the resulting commit on `dev` and use that tag for promotion.

**4. Promote environment branches to the hotfix tag**

Same as a standard release — fast-forward `preprod` then `prod`, verifying each before
moving to the next.

**5. Clean up the hotfix branch**

```bash
git branch -d hotfix/vx.y.z
git push origin --delete hotfix/vx.y.z
```

---

## Dependency maintenance

```bash
./bin/bundle outdated --only-explicit   # Check for outdated gems
yarn upgrade-interactive                # Interactive Node module upgrades
```
