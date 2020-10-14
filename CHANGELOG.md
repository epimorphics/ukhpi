# Changes to the UKHPI app by version and date

## 1.5.12 - 2020-10-13 (Ian)

- fix link to broken page at linkeddata.org
- link to Welsh-language versions of some pages
- fix broken rendering of 'about UKHPI' page
- fix mutation of location names in non-JS view

## 1.5.11 - 2020-10-07 (Ian)

- Adjust the map UI to make the role of the layer selector (countries,
  counties LA's etc) clearer

## 1.5.10 - 2020-10-05 (Ian)

- Some additional Welsh language refinements, in particular date abbreviations

## 1.5.9 - 2020-10-02 (Ian)

- Additional fixes to the Welsh language localisation, including some
  corrections to Welsh mutations
- added Welsh version of accessibility statement

## 1.5.8 - 2020-09-29 (Ian)

- Update Rails and JS dependencies
- Various additional Welsh translation fixes, including support for
  consonant mutations (nb: this is a retrospective entry for the
  previous PR)

## 1.5.7 - 2020-09-24 (Ian)

- Fix problem `$t is not defined`, GH-263

## 1.5.6 - 2020-09-23 (Ian)

- Added accessibility statement

## 1.5.5 - 2020-09-22 (Ian)

- Fix WCAG colour contrast issue, and improve visual consistency by
  picking dark blue as the primary action colour

## 1.5.4 - 2020-09-22 (Ian)

- added skip-to-main-content link

## 1.5.3 - 2020-09-18 (Ian)

Updates to Welsh localization based on testing

- migrated some UKHPI documents (e.g changelog, about) into the
  UKHPI repo
- missing entries from message catalogue
- added a framework for consonant mutations and other grammar rule fixes

## 1.5.2 - 2020-09-17 (Ian)

A collection of fixes for various reported WCAG violations:

- fixed colour contrast in the footer
- added missing alt-text and aria roles on images and links
- ensure that all content is contained in landmarks
- ensure that all form elements have labels
- ensure that every page has an h1 element
- fix colour contrast issue in buttons by switching colour to
  GDS green
- fixed missing aria labels on buttons
- added focus-trapping and auto-focus for modal dialogues

## 1.5.1 - 2020-09-16 (Ian)

- Fix for GH-248: missing local authorities when using Welsh language
  mode. The change is to ensure that in the compiled `locations-data.js`
  and `locations_table.rb` files, we always have two labels (Welsh and
  English) for locations, even if it means re-using the English label.
  This is correct for Welsh LA's (e.g. Gwynedd), and a convenient
  approximation for English LA's that don't have an existing Welsh translation.

## 1.5.0 - 2020-09-14 (Ian)

- Added Welsh language mode for UKHPI

## 1.4.0 - 2020-08-13 (Ian)

- Beginning the process of moving to a Docker-based deployment pattern
  by adding an initial Dockerfile and adding some build support via a
  Makefile.

## 1.3.2 - 2020-07-6

- Update various gem dependencies to resolve CVE warnings
- Remove old warning about Bournemouth, Christchurch and Poole as client
  indicated it is no longer relevant

## 1.3.1

- Update `package.json` to constrain the version of `@babel/preset-env` to avoid
  build regression. GH-229

## 1.3.0

- Updated to latest version of locations and boundaries
  of local authorities

## 1.2.10

- Update `rack` gem in response to CVE-2019-16782

## 1.2.9

- Update the link to download all data in CSV (GH-215)

## 1.2.8 - 2019-12-17

- Do not error if the user requests MIME type JSON but sends
  an incorrectly encoded request

## 1.2.7 - 2019-12-10

- Ensure that a badly coded GSS code for the location results in a
  `BadArgument` error and hence an HTTP 400 response

## 1.2.6 - 2019-12-09

- Add `ActionController::BadRequest` to the list of exceptions that
  Sentry will ignore

## 1.2.5 - 2019-12-05

- Fix regression in use of unprotected `%` character in calls
  to `String.format` in Ruby 2.6

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

- Following build issues, the entire webpacker subsystem has been
  upgraded. This seems sufficient to warrant bumping the minor
  version number.
- Fix GH-205 to fix regression in data tables introduced by the build
  and dependency changes.

## 1.1.1 2019-07-17

- Update Rubygem and NPM dependencies to address CVEs

## 1.1.0 2019-06-03

Additions:

- GH-203 - show a warning when the user selects a location that does not
  yet have available statistics
