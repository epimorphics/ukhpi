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

if [ -z "API_SERVICE_URL" ]
then
  echo "{'ts': '`date -Iseconds`', 'message': {'text: 'You have not specified an API_SERVICE_URL', 'level': 'ERROR'}}" >&2
  exit 1
fi

echo "{'ts': '`date -Iseconds`', 'message': {'text: 'UKHPI starting with API_SERVICE_URL ${API_SERVICE_URL}', 'level': 'INFO'}}"

# Handle secrets based on env
if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  export SECRET_KEY_BASE=`./bin/rails secret`
fi

export RAILS_RELATIVE_URL_ROOT=${RAILS_RELATIVE_URL_ROOT:-'/app/ukhpi'}
export SCRIPT_NAME=${RAILS_RELATIVE_URL_ROOT}

exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0
