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

# RUN apk add --update --no-cache \
#     bash \
#     coreutils \
#     git \
#     npm \
#     nodejs \
#     tzdata \
#     yaml-dev \
#     && gem update --system

# Copy node binaries from the official image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Remove existing global yarn and pnpm installs from the node image to avoid
# conflicts with the project's Yarn Berry version in .yarn/releases
RUN npm uninstall -g yarn pnpm

# Install a specific version of bundler
ARG BUNDLER_VERSION
RUN echo "Bundler version ${BUNDLER_VERSION}"
RUN gem install bundler:$BUNDLER_VERSION

# COPY bin bin
COPY Gemfile Gemfile.lock ./
# .bundle/config contains the information required to access rubygems.pkg.github.com/epimorphics/
COPY .bundle/config /root/.bundle/config

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# RUN bundle config set --local without 'development test' \
#     && bundle config set --local frozen 1 \
#     && bundle install

# for Yarn
# RUN npm install -g corepack
# RUN corepack enable

# installs the required gems
# FROM base AS gems
# RUN apk add --update build-base && gem update --system

# install the required node modules
# FROM base AS npm
# RUN apk add --update build-base && gem update --system

# WORKDIR ${DIR}
# COPY package.json yarn.lock .yarnrc.yml ./
COPY package.json yarn.lock ./
COPY .yarn .yarn
RUN yarn install --immutable

# runs build to compile assets
# FROM base AS builder
# RUN apk add --update build-base && gem update --system

# WORKDIR ${DIR}
# # Copy the builds from the previous stages
# COPY --from=gems --chown=app /usr/local/bundle /usr/local/bundle
# COPY --from=npm --chown=app ${DIR}/node_modules ./node_modules

# # Copy the rest of the application code

COPY postcss.config.js ./
COPY config.ru Rakefile ./
COPY vite.config.mts ./
# COPY package.json yarn.lock vite.config.mts .yarnrc.yml ./

COPY app app
COPY bin bin
COPY config config
COPY lib lib
COPY public public

ARG RAILS_RELATIVE_URL_ROOT
RUN echo "VITE_RUBY_BASE set to: ${RAILS_RELATIVE_URL_ROOT}"

# Precompile assets and build vite
RUN RAILS_ENV=production \
    VITE_RUBY_BASE=$RAILS_RELATIVE_URL_ROOT \
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

# Copy just the distribution requirements from the previous stage
COPY --from=builder ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=builder --chown=app ${APP_DIR}/app ./app
COPY --from=builder --chown=app ${APP_DIR}/bin/rails ./bin/rails
COPY --from=builder --chown=app ${APP_DIR}/config ./config
COPY --from=builder --chown=app ${APP_DIR}/config.ru ${APP_DIR}/Gemfile ${APP_DIR}/Gemfile.lock ./
COPY --from=builder --chown=app ${APP_DIR}/lib ./lib
COPY --from=builder --chown=app ${APP_DIR}/public ./public
COPY --from=builder --chown=app ${APP_DIR}/tmp ./tmp

USER app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh ./

ENTRYPOINT ["sh", "entrypoint.sh"]
