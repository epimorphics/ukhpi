# Changes to the UKHPI app by version and date

## 1.7.5 - 2024-08

- (Jon) Exposed `instrument_internal_error(exception)` metric to the
  `ExceptionsController` to provide a count of internal errors
  [GH-142](https://github.com/epimorphics/hmlr-linked-data/issues/142)
- (Jon) Added puma.stats to footer template in development environment only,
  again as per the approach in the [`LR_Common_Styles`
  gem](https://github.com/epimorphics/lr_common_styles/releases/tag/1.9.6)
- (Jon) Adjusted footer `link_to` helpers to only appending the lang parameter
  to the url only if it exists for "internal" links as per the approach in the
  [`LR_Common_Styles`
  gem](https://github.com/epimorphics/lr_common_styles/releases/tag/1.9.6)
- (Jon) Adjusted fix for visual contrast in the location selection menu via
  additional styling and updated 3rd-party element use specific to ticket
  [GH-408](https://github.com/epimorphics/ukhpi/issues/408) alongside adding
  missing aria-attributes required for assisted use
- (Jon) Implements revised approach to page titles mirrored on other suite apps,
  as well as fixes white space typo in some concatenated page titles
- (Jon) Added `process_threads` guage to prometheus metrics alongside isolating
  thread counts to specific status' as per the Rails thread documentation as
  well as updating the approach to resolve
  [GH-142](https://github.com/epimorphics/hmlr-linked-data/issues/142)
- (Jon) Excluded prometheus metrics from the testing environment to reduce noise
  in the logs
- (Jon) Added `puma-metrics` gem to provide base metrics for the Puma web server
- (Jon) Updated .rubocop.yml primarily reorganising the rules alphabetically as
  well as adding `CountAsOne` to both `Metrics/ClassLength` and
  `Metrics/MethodLength`; includes files with removed earlier disabling of said
  rules!
- (Jon) Updated `.gitignore` to include ignoring byebug history as well as sets
  the tmp directory ignore to be anywhere, not just at the project root
- (Bogdan) Fixed a bug where CSS was being applied to the wrong element
  [GH-412](https://github.com/epimorphics/ukhpi/issues/412)
- (Bogdan) Fixed type in aria-label text
  [GH-416](https://github.com/epimorphics/ukhpi/issues/416)
- (Dan) Fixed aria-label in compare locations form [GH-416](https://github.com/epimorphics/ukhpi/issues/416)
- (Dan) Adds `aria-label` link attributes on the about page to SPARQL link
  [GH-413](https://github.com/epimorphics/ukhpi/issues/413)
- (Bogdan) Fixed a bug where CSS was being applied to the wrong element 
  [GH-412](https://github.com/epimorphics/ukhpi/issues/412)
- (Bogdan) Fixed type in aria-label text [GH-416](https://github.com/epimorphics/ukhpi/issues/416)
- (Bogdan) Fixed a duplicate character bug when selecting dates
- (Bogdan) Added page titles for each individual view
  [GH-409](https://github.com/epimorphics/ukhpi/issues/409)
- (Bogdan) Set correct values for `aria-label` link attributes on the about page
  [GH-413](https://github.com/epimorphics/ukhpi/issues/413)
- (Bogdan) Increased contrast for compare location dropdowns
  [GH-412](https://github.com/epimorphics/ukhpi/issues/412)
- (Bogdan) Increased contrast for search location results, as well as when they
  are being focused [GH-412](https://github.com/epimorphics/ukhpi/issues/412)
- (Bogdan) CSS Refactoring
- (Bogdan) Fixed a bug where CSS was applied to the wrong element, causing
  search location results to be displayed incorrectly
- (Bogdan) Increased focusable area for close button on modal and hide graph
  button [GH-411](https://github.com/epimorphics/ukhpi/issues/411)
- (Bogdan) Increased contrast for search location input and map elements, as
  well as all modal buttons
  [GH-408](https://github.com/epimorphics/ukhpi/issues/408)
- (Bogdan) Increased contrast of modal warning message
  [GH-407](https://github.com/epimorphics/ukhpi/issues/407)
- (Bogdan) Increased contrast for modal close button and body
  [GH-407](https://github.com/epimorphics/ukhpi/issues/407)
- (Bogdan) Landing page links should now be more visible
  [GH-406](https://github.com/epimorphics/ukhpi/issues/406)
- (Bogdan) Added alt text to application logo
  [GH-404](https://github.com/epimorphics/ukhpi/issues/404)

## 1.7.4 - 2024-04-19

- (Jon) Updated print presenter to use
  [`.try(:first)`](https://apidock.com/rails/Object/try) which resolves by
  returning `nil` without failing if the requested element does not have the
  method `.first`, i.e. is empty or nil
  [GH-396](https://github.com/epimorphics/ukhpi/issues/396)
- (Jon) Updated the print template to include the Google Analytics tracking
  script for the print page as well as importing shared header content for
  unification of presentation
- (Jon) Minor tweaks to the Makefile to remove duplicate variables (`SHORTNAME`)
  as well as introducing new targets for `check` and `local` for streamlined
  development tasks

## 1.7.3 - 2024-03-15

- (Jon) Updated puma.rb configuration to accept both `RAILS_MIN_THREADS` and
  `RAILS_MAX_THREADS` environment variables to allow a more flexible
  configuration for the application to run in different environments.
  [GH-143](https://github.com/epimorphics/hmlr-linked-data/issues/143)
- (Jon) Updated the UKHPI contact form links to point to the new contact form
  page; both the English and Welsh versions
  [GH-135](https://github.com/epimorphics/hmlr-linked-data/issues/135)
- (Jon) Update to add `www` to the ONS url links on the landing page
  [GH-133](https://github.com/epimorphics/hmlr-linked-data/issues/133)

## 1.7.1 - 2023-06-23

- (Jon) Updated the `data_service_api` gem to the latest 1.4.1 patch release
  version.
- (Jon) Updated the `json_rails_logger` gem to the latest 1.0.3 patch release
  - Also includes minor patch updates for other gems, please see the
  `Gemfile.lock` for details.

## 1.7.0 - 2023-06-22

- (Jon) Added `NoMethodError` rescue clause set to `debug` level to reduce
  logging noise in production as this should be caught in development and test
  environments.
- (Jon) Improved logging by using blocks instead of strings as Ruby has to
  evaluate these strings, which includes instantiating the somewhat heavy String
  object and interpolating the variables, and which takes time. Therefore, it's
  recommended to pass blocks to the logger methods, as these are only evaluated
  if the output level is the same or included in the allowed level (i.e. lazy
  loading).
  [Documentation](http://guides.rubyonrails.org/debugging_rails_applications.html#impact-of-logs-on-performance)
- (Jon) Removed sentry logging from dev instance
- (Jon) Improved logging status with allowance for the differences between 400
  and 500 errors handled by the same method.
- (Jon) Improved Javascript asset delivery by adding `defer` to the script tags.
  If the defer attribute is set, it specifies that the script is downloaded in
  parallel to parsing the page, and executed after the page has finished
  parsing.
- (Jon) Resolves error level reported to match logs where the logging was
  reporting 400 instead of 500
- (Jon) Improved webpacker setup to match newer applications
- (Jon) Improved logging in perform_query method by combining generated logs
  into single log for better message
- (Jon) Resolves rubocop OpenStruct warning
- (Jon) Now uses the proper logging level as well as provides more details to
  the logs for the `json_rails_logger` gem
- (Jon) Refactored cache control - resolves
  [GH-114](https://github.com/epimorphics/hmlr-linked-data/issues/114)
- (Jon) Updated header links to apply the appropriate language to the root link
- (Jon) Updated errors reported as `info` level to `error` level - also resolves
  the `DEBUG level logs seen in production` issues on this file.
- (Jon) Updated the `data_service_api` gem to the latest 1.4.0 minor release
  version.
  - Also includes minor patch updates for other gems, please see the
  `Gemfile.lock` for details.

## 1.6.3 - 2023-06-07

- (Jon) Updated the `json_rails_logger` gem to the latest 1.0.1 patch release.
  - Also includes minor patch updates for gems, please see the `Gemfile.lock`
  for details.

## 1.6.2 - 2023-06-03

- (Jon) Updated the `json_rails_logger` gem to the latest 1.0.0 release.

## 1.6.1 - 2023-04-19

- (Jon) Complete re-write of the README information to ensure inclusion of
  latest changes and emphasis where required is met. Also now links to the
  appropriate additional tools needed to develop and test both the individual
  app and the HMLR suite locally.
- (Jon) Updated the `makefile` and `dockerfile` files to ensure the correct
  commands are used for development and release.
- (Jon) Refactors the elapsed time calculated for API requests to be resolved as
  microseconds rather than milliseconds. This is to improve the reporting of the
  elapsed time in the system tooling logs.
- (Jon) Minor text changes to the `Gemfile` to include instructions for running
  Epimorphics specific gems locally during the development of those gems.
- (Jon) Updated the production `json_rails_logger` gem version to be at least
  the current version `~>0.3.5` to cover out-of-sync release versions.
- (Jon) Updated the production `data_services_api` gem version to be at least
  the current version`~>1.3.3` to cover out-of-sync release versions.
- (Jon) Removed 'test' environment from sentry configuration to reduce
  unecessary monitoring charges
- (Jon) Updated the `sentry-rails` gem version to the current version`~>5.7`
  following warnings in the sentry dashboard about the out of date gem version
  being used.
- (Jon) Refactored better guards in `entrypoint.sh` to ensure the required env
  vars are set accordingly or deployment will fail noisily.
- (Jon) Refactored better guards in `configs/environment/production.rb` to
  ensure the required env vars are set accordingly or deployment will fail
  noisily.
- (Jon) Refactored the version cadence creation to include the PATCH property as
  per other Epimorphics apps.
- (Jon) Refactored the version cadence creation to include a SUFFIX value if
  provided; otherwise no SUFFIX is included in the version number.

## 1.6.0 - 2022-04-07

- (Ian) Adopt all of the current Epimorphics best-practice deployment patterns,
  including shared GitHub actions, updated Makefile and Dockerfile, Prometheus
  monitoring, and updated version of Sentry.
- (Ian) Updated the README as part of handover.

## 1.5.20 - 2023-04-17

- (Jon) Updated English & Welsh translations of the Changelog for current
  releases
- (Jon) Updated English & Welsh translations of the Landing page
- (Jon) Updated `version.rb` to include `SUFFIX` parameter for improved release
  cadence
- (Jon) Updated `package.json` to include current release cadence
- (Jon) Updated English Changelog for April 2023 Release
- (Jon) Updated English Changelog for Oct 2021 Release
- (Jon) Update Element-UI to latest 2.15.13 version
- (Jon) Updated .gitignore to handle dev files
- (Jon) updated to lock node to v14.21.3
- (Jon) Updated Land Boundaries to respective files
- (Jon) Update to include IE11 coverage for webpack

## 1.5.19.1 - 2021-12-09

- (Mairead) Update deployment workflow, dockerfile and assisting scripts
- (Joseph) Add link to privacy notice to footer
- (Joseph) Update gem dependencies
- (Joseph) Update yarn package dependencies

## 1.5.19 - 2021-06-28

- (Joseph) Add link to privacy notice to footer
- (Joseph) Update gem dependencies
- (Joseph) Update yarn package dependencies

## 1.5.18 - 2021-06-24

- (Joseph) Add localised text for Wales to the cookie banner

## 1.5.17 - 2021-05-04

- (Ian) Fix for GH-15: error 500 instead of HTTP 400 when user chooses a
  non-recognised location

## 1.5.16 - 2021-04-27

- (Ian) Updated correction to email address (GH-3)

## 1.5.15 - 2021-02-18

- (Ian) Some Welsh-language fixes suggested by Eleri

## 1.5.14 - 2021-01-20

- (Ian) Enable use of Welsh langauge affordances in all deployment environments

## 1.5.13 - 2021-01-12 (Ian)

- Updated regions for new Buckinghamshire UA creation
- update dependencies

## 1.5.12 - 2020-10-13 (Ian)

- fix link to broken page at linkeddata.org
- link to Welsh-language versions of some pages
- fix broken rendering of 'about UKHPI' page
- fix mutation of location names in non-JS view

## 1.5.11 - 2020-10-07 (Ian)

- Adjust the map UI to make the role of the layer selector (countries, counties
  LA's etc) clearer

## 1.5.10 - 2020-10-05 (Ian)

- Some additional Welsh language refinements, in particular date abbreviations

## 1.5.9 - 2020-10-02 (Ian)

- Additional fixes to the Welsh language localisation, including some
  corrections to Welsh mutations
- added Welsh version of accessibility statement

## 1.5.8 - 2020-09-29 (Ian)

- Update Rails and JS dependencies
- Various additional Welsh translation fixes, including support for consonant
  mutations (nb: this is a retrospective entry for the previous PR)

## 1.5.7 - 2020-09-24 (Ian)

- Fix problem `$t is not defined`, GH-263

## 1.5.6 - 2020-09-23 (Ian)

- Added accessibility statement

## 1.5.5 - 2020-09-22 (Ian)

- Fix WCAG colour contrast issue, and improve visual consistency by picking dark
  blue as the primary action colour

## 1.5.4 - 2020-09-22 (Ian)

- added skip-to-main-content link

## 1.5.3 - 2020-09-18 (Ian)

Updates to Welsh localization based on testing

- migrated some UKHPI documents (e.g changelog, about) into the UKHPI repo
- missing entries from message catalogue
- added a framework for consonant mutations and other grammar rule fixes

## 1.5.2 - 2020-09-17 (Ian)

A collection of fixes for various reported WCAG violations:

- fixed colour contrast in the footer
- added missing alt-text and aria roles on images and links
- ensure that all content is contained in landmarks
- ensure that all form elements have labels
- ensure that every page has an h1 element
- fix colour contrast issue in buttons by switching colour to GDS green
- fixed missing aria labels on buttons
- added focus-trapping and auto-focus for modal dialogues

## 1.5.1 - 2020-09-16 (Ian)

- Fix for GH-248: missing local authorities when using Welsh language mode. The
  change is to ensure that in the compiled `locations-data.js` and
  `locations_table.rb` files, we always have two labels (Welsh and English) for
  locations, even if it means re-using the English label. This is correct for
  Welsh LA's (e.g. Gwynedd), and a convenient approximation for English LA's
  that don't have an existing Welsh translation.

## 1.5.0 - 2020-09-14 (Ian)

- Added Welsh language mode for UKHPI

## 1.4.0 - 2020-08-13 (Ian)

- Beginning the process of moving to a Docker-based deployment pattern by adding
  an initial Dockerfile and adding some build support via a Makefile.

## 1.3.2 - 2020-07-6

- Update various gem dependencies to resolve CVE warnings
- Remove old warning about Bournemouth, Christchurch and Poole as client
  indicated it is no longer relevant

## 1.3.1

- Update `package.json` to constrain the version of `@babel/preset-env` to avoid
  build regression. GH-229

## 1.3.0

- Updated to latest version of locations and boundaries of local authorities

## 1.2.10

- Update `rack` gem in response to CVE-2019-16782

## 1.2.9

- Update the link to download all data in CSV (GH-215)

## 1.2.8 - 2019-12-17

- Do not error if the user requests MIME type JSON but sends an incorrectly
  encoded request

## 1.2.7 - 2019-12-10

- Ensure that a badly coded GSS code for the location results in a `BadArgument`
  error and hence an HTTP 400 response

## 1.2.6 - 2019-12-09

- Add `ActionController::BadRequest` to the list of exceptions that Sentry will
  ignore

## 1.2.5 - 2019-12-05

- Fix regression in use of unprotected `%` character in calls to `String.format`
  in Ruby 2.6

## 1.2.4 - 2019-10-10

- general update of gem versions
- fix deprecation warnings from MiniTest
- add release to Sentry configuration

## 1.2.3 2019-08-20

- Fix for GH-209: UKHPI not working on IE 11

## 1.2.2 2019-08-16

- Fix for GH-207: Sentry warning about circular data structures
- updated Sentr SDK to the new browser API

## 1.2.1 2019-08-15

- Fix for GH-206 to resolve over-large orange background on print button

## 1.2.0 2019-07-17

- Following build issues, the entire webpacker subsystem has been upgraded. This
  seems sufficient to warrant bumping the minor version number.
- Fix GH-205 to fix regression in data tables introduced by the build and
  dependency changes.

## 1.1.1 2019-07-17

- Update Rubygem and NPM dependencies to address CVEs

## 1.1.0 2019-06-03

Additions:

- GH-203 - show a warning when the user selects a location that does not yet
  have available statistics
