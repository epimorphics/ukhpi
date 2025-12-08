ARG RUBY_VERSION=3.4.4
ARG NODE_VERSION=24
ARG ALPINE_VERSION=3.22
ARG BUNDLER_VERSION=2.7.2

# Load node from official build
FROM node:$NODE_VERSION-alpine AS node

# Define the base image
FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION AS base

ENV APP_DIR=/rails \
    RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

WORKDIR ${APP_DIR}

RUN apk add --no-cache \
    curl \
    jemalloc \
    tzdata

FROM base AS builder

# Install packages required to build gems
RUN apk add --update --no-cache \
    bash \
    build-base \
    coreutils \
    git \
    pkgconf \
    yaml-dev \
    && gem update --system

# Copy node binaries from the official image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Remove bundled yarn/pnpm and reinstall corepack for future Node.js 25+ compatibility
# Corepack is bundled with Node < 25 but will be removed in Node 25+
# See: https://github.com/nodejs/corepack?tab=readme-ov-file#manual-installs
RUN npm uninstall -g yarn pnpm && \
    npm install -g corepack && \
    corepack enable

# Install a specific version of bundler
ARG BUNDLER_VERSION
RUN echo "Bundler version ${BUNDLER_VERSION}"
RUN gem install bundler:$BUNDLER_VERSION

# Copy Gemfile and lockfile to install gems
COPY Gemfile Gemfile.lock ./
# .bundle/config contains the information required to access rubygems.pkg.github.com/epimorphics/
COPY .bundle/config /root/.bundle/config

# Install gems and clean up unnecessary files
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules using Yarn via Corepack
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN yarn install --immutable

# # Copy the rest of the application code
COPY postcss.config.js ./
COPY vite.config.mts ./
COPY config.ru Rakefile ./
COPY app app
COPY bin bin
COPY config config
COPY lib lib
COPY public public

ARG RAILS_RELATIVE_URL_ROOT
RUN echo "VITE_RUBY_BASE set to: ${RAILS_RELATIVE_URL_ROOT} for ${RAILS_ENV} build"

# Precompile assets and build vite
RUN VITE_RUBY_BASE=$RAILS_RELATIVE_URL_ROOT \
    NODE_OPTIONS=--max-old-space-size=4096 \
    bundle exec rake vite:build

# Start a new stage to minimise the final image size
FROM base

WORKDIR ${APP_DIR}

ARG image_name
ARG git_branch
ARG git_commit_hash
ARG github_run_number
ARG VERSION

LABEL com.epimorphics.name=$image_name \
      com.epimorphics.branch=$git_branch \
      com.epimorphics.build=$github_run_number \
      com.epimorphics.commit=$git_commit_hash \
      com.epimorphics.version=$VERSION

RUN addgroup -S app && adduser -S -G app app
EXPOSE 3000

WORKDIR ${DIR}

COPY --from=builder --chown=app /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=app ${DIR} .

USER app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh "app/entrypoint.sh"
ENTRYPOINT ["sh", "app/entrypoint.sh"]
