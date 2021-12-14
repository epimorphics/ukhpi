#!/bin/bash

# Set the environment
if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
  export RAILS_SERVE_STATIC_FILES=true
  export RAILS_LOG_TO_STDOUT=true
  export RAILS_RELATIVE_URL_ROOT='/app/ukhpi'
  export SCRIPT_NAME=$RAILS_RELATIVE_URL_ROOT
  export API_SERVICE_URL = 'http://localhost:8080'
fi


# Handle secrets based on env
if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  export SECRET_KEY_BASE=`./bin/rails secret`
fi

exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0

