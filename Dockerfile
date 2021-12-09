ARG ALPINE_VERSION=3.10
ARG RUBY_VERSION=2.6.6

# Defines base image which builder and final stage use
FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION as base

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

LABEL Name=ukhpi version=${APP_VERSION}

WORKDIR /usr/src/app
COPY . .

RUN bundle config set --local without 'development' \
  && bundle install \
  && yarn install \
  && RAILS_ENV=production bundle exec rake assets:precompile \
  && mkdir -p 777 /usr/src/app/coverage \
  && rm -rf node_modules

# Start a new build stage to minimise the final image size
FROM base

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_RELATIVE_URL_ROOT='/app/ukhpi'
ENV SCRIPT_NAME=$RELATIVE_URL_ROOT
ENV API_SERVICE_URL = 'http://localhost:8080'

RUN addgroup -S app && adduser -S -G app app
EXPOSE 3000

WORKDIR /usr/src/app

COPY --from=builder --chown=app /usr/local/bundle /usr/local/bundle
COPY --from=builder /usr/src/app     ./app

RUN chown -R app .

USER app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /app
ENTRYPOINT ["sh", "/app/entrypoint.sh"]
