#!/bin/bash

# Set the environment
if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
fi

# Start the server
bundle exec rails server