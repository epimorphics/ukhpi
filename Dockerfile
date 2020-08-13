ARG ALPINE_VERSION=3.10
ARG RUBY_VERSION

# Defines base image which builder and final stage use
FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION as base

# Change this is Gemfile.lock bundler version changes
ARG BUNDLER_VERSION

RUN apk add --update \
  build-base \
  npm \
  tzdata \
  git \
  && rm -rf /var/cache/apk/* \
  && gem install bundler:$BUNDLER_VERSION \
  && bundle config --global frozen 1 \
  && npm install -g yarn

FROM base as builder

ARG APP_VERSION
LABEL Name=ukhpi version=${APP_VERSION}

WORKDIR /usr/src/app
COPY . .

RUN bundle install --without="development" \
  && yarn install \
  && RAILS_ENV=production rake assets:precompile \
  && mkdir -p 777 /usr/src/app/coverage \
  && rm -rf node_modules

# Start a new build stage to minimise the final image size
FROM base

RUN addgroup -S app && adduser -S -G app app
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_RELATIVE_URL_ROOT='/'
EXPOSE 3000

WORKDIR /usr/src/app

COPY --from=builder --chown=app /usr/src/app /usr/src/app
COPY --from=builder --chown=app /usr/local/bundle /usr/local/bundle

USER app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/src/app/
ENTRYPOINT ["sh", "/usr/src/app/entrypoint.sh"]
