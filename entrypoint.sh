#!/bin/bash
set -e

# Remove any pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid
mkdir -pm 1777 ./tmp

# This is set to the name of the application for logging purposes
PUBLIC_NAME="UK Housing Price Index"

# Set the environment
[ -z "$RAILS_ENV" ] && RAILS_ENV=production


echo "{\"ts\": $(date -u +%FT%T.%3NZ), \"level\": \"INFO\", \"message\": \"Initiating ${PUBLIC_NAME} application using APPLICATION_ROOT=${APPLICATION_ROOT}, API_SERVICE_URL=${API_SERVICE_URL}}"

if [ -z "$API_SERVICE_URL" ]
then
  echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"ERROR\",\"message\":\"API_SERVICE_URL not set\"}" >&2
  exit 1
else
  echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"API_SERVICE_URL=${API_SERVICE_URL}\"}"
fi

# Handle secrets based on env
[ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ] && export SECRET_KEY_BASE=$(./bin/rails secret)

[ -n "${RAILS_RELATIVE_URL_ROOT}" ] && echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"RAILS_RELATIVE_URL_ROOT=${RAILS_RELATIVE_URL_ROOT}\"}"

echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0\"}"

exec ./bin/rails server -e "${RAILS_ENV}" -b 0.0.0.0
