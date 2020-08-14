#!/bin/bash
set -e

if [ -z "$WORKDIR" ]
then
  export WORKDIR=/usr/src/app
fi

cd ${WORKDIR}

# Remove a potentially pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid

if [ -z "$API_SERVICE_URL" ]
then
  echo "Environment Variable \$API_SERVICE_URL not defined." >&2
  exit 1
fi

if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
fi

if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  echo "Setting environment variable \$SECRET_KEY_BASE."
  export SECRET_KEY_BASE=`./bin/rails secret`
fi

exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0
