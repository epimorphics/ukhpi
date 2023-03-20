#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid
mkdir -pm 1777 ./tmp

# This is set to the name of the application for logging purposes
PUBLIC_NAME="UK Housing Price Index"

# Set the environment
if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
fi


echo "{\"ts\": $(date -u +%FT%T.%3NZ), \"level\": \"INFO\", \"message\": \"Initiating ${PUBLIC_NAME} application using APPLICATION_ROOT=${APPLICATION_ROOT}, API_SERVICE_URL=${API_SERVICE_URL}}"

if [ -z "$API_SERVICE_URL" ]
then
  echo "{\"ts\": $(date -u +%FT%T.%3NZ), \"level\": \"ERROR\", \"message\": \"You have not specified the env var API_SERVICE_URL\"}" >&2
  exit 1
fi

# Handle secrets based on env
if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  SECRET_KEY_BASE=$(./bin/rails secret)
  export SECRET_KEY_BASE
fi

export RAILS_RELATIVE_URL_ROOT=${APPLICATION_ROOT:-'/app/ukhpi'}
export SCRIPT_NAME=${RAILS_RELATIVE_URL_ROOT}

echo "{\"ts\": $(date -u +%FT%T.%3NZ), \"level\": \"INFO\", \"message\": \"Starting ${PUBLIC_NAME} application with RAILS_ENV=\"${RAILS_ENV}\", \"RAILS_RELATIVE_URL_ROOT\"=\"${RAILS_RELATIVE_URL_ROOT}\", \"SCRIPT_NAME\"=\"${SCRIPT_NAME}\"}"

exec ./bin/rails server -e "${RAILS_ENV}" -b 0.0.0.0
