ARG ALPINE_VERSION=3.10
ARG RUBY_VERSION=2.6.6

# Defining ruby version
FROM ruby:$RUBY_VERSION-alpine

# Change this is Gemfile.lock bundler version changes
ARG BUNDLER_VERSION=2.2.17

RUN apk add --update \
  npm \
  tzdata \
  git \
  && rm -rf /var/cache/apk/* \
  && gem install bundler:$BUNDLER_VERSION \
  && bundle config --global frozen 1 \
  && npm install -g yarn

FROM base as builder

RUN apk add --update build-base

ARG APP_VERSION=0.1
ARG GRP_TOKEN
ARG GRP_OWNER=epimorphics

LABEL Name=ukhpi version=${APP_VERSION}

WORKDIR /usr/src/app
COPY . .

# Prerequisites for gems install
RUN apk add build-base \
            npm \
            tzdata \
            git

ARG BUNDLER_VERSION=2.1.4

ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_RELATIVE_URL_ROOT='/'
ENV API_SERVICE_URL = 'http://localhost:8080'

RUN addgroup -S app && adduser -S -G app app
EXPOSE 3000

# Install gems and yarn dependencies
RUN bundle install
RUN yarn install

# Params
ARG RAILS_ENV="production"
ARG RAILS_SERVE_STATIC_FILES="true"
ARG RELATIVE_URL_ROOT="/app/ukhpi"
ARG API_SERVICE_URL

# Set environment variables and expose the running port
ENV RAILS_ENV=$RAILS_ENV
ENV RAILS_SERVE_STATIC_FILES=$RAILS_SERVE_STATIC_FILES
ENV RELATIVE_URL_ROOT=$RELATIVE_URL_ROOT
ENV SCRIPT_NAME=$RELATIVE_URL_ROOT
ENV API_SERVICE_URL=$API_SERVICE_URL
EXPOSE 3000

# Precompile assets and add entrypoint script
RUN rake assets:precompile
ENTRYPOINT [ "sh", "./entrypoint.sh" ]