#!/bin/bash

# Set the environment
if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
fi

# Handle secrets based on env
if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  export SECRET_KEY_BASE=`./bin/rails secret`
fi

exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0

