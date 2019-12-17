# Changes to the UKHPI app by version and date

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
