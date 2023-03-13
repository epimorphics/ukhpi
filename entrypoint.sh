#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid
mkdir -pm 1777 ./tmp

# Set the environment
if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
fi

[ -z "API_SERVICE_URL" ] && echo "{'ts': '`date -u +%FT%T.%3NZ`', 'message': {'text: 'You have not specified env var API_SERVICE_URL', 'level': 'ERROR'}}" >&2

[ -z "APPLICATION_ROOT" ] && echo "{'ts': '`date -u +%FT%T.%3NZ`', 'message': {'text: 'You have not specified env var APPLICATION_ROOT', 'level': 'ERROR'}}" >&2

if [ -z "API_SERVICE_URL" ] || [-z "APPLICATION_ROOT"]
then
  exit 1
fi

echo "{'ts': '`date -u +%FT%T.%3NZ`', 'message': {'text: 'UKHPI starting with API_SERVICE_URL ${API_SERVICE_URL} at APPLICATION_ROOT ${APPLICATION_ROOT}', 'level': 'INFO'}}"

# Handle secrets based on env
if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  export SECRET_KEY_BASE=`./bin/rails secret`
fi

export RAILS_RELATIVE_URL_ROOT=${APPLICATION_ROOT:-'/app/ukhpi'}
export SCRIPT_NAME=${APPLICATION_ROOT}

exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0
