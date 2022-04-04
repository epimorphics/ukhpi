ARG ALPINE_VERSION
ARG RUBY_VERSION

# Defines base image which builder and final stage use
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} as base
ARG BUNDLER_VERSION

RUN apk add --update \
    tzdata \
    git \
    nodejs \
    npm \
    && rm -rf /var/cache/apk/* \
    && gem install bundler:$BUNDLER_VERSION \
    && bundle config --global frozen 1 \
    && npm install -g yarn

FROM base as builder

RUN apk add --update build-base

WORKDIR /usr/src/app

COPY config.ru Dockerfile entrypoint.sh Gemfile Gemfile.lock Rakefile package.json babel.config.js postcss.config.js yarn.lock ./
COPY app app
COPY bin bin
COPY config config
COPY lib lib
COPY public public
RUN mkdir log

# Copy the bundle config
# **Important** the destination for this copy **must not** be in WORKDIR,
# or there is a risk that the GitHub PAT could be part of the final image
# in a potentially leaky way
COPY .bundle/config /root/.bundle/config

RUN ./bin/bundle config set --local without 'development test'

RUN ./bin/bundle install \
  && yarn install \
  && RAILS_RELATIVE_URL_ROOT=/app/ukhpi RAILS_ENV=production bundle exec rake assets:precompile \
  && mkdir -p 777 /usr/src/app/coverage

ARG BUNDLER_VERSION=2.1.4

RUN addgroup -S app && adduser -S -G app app
EXPOSE 3000

# Install gems and yarn dependencies
RUN bundle install
RUN yarn install

COPY --from=builder --chown=app /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=app /usr/src/app     .

USER app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh "/app/entrypoint.sh"
ENTRYPOINT ["sh", "/app/entrypoint.sh"]
