#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid
mkdir -pm 1777 ./tmp

# Set the environment
if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
  export API_SERVICE_URL = 'http://localhost:8080'
fi

echo PI_SERVICE_URL:  ${API_SERVICE_URL}

# Handle secrets based on env
if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  export SECRET_KEY_BASE=`./bin/rails secret`
fi

export SCRIPT_NAME=${RAILS_RELATIVE_URL_ROOT}

exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0

