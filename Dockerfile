ARG RUBY_VERSION=3.3.5
ARG NODE_VERSION=20
ARG ALPINE_VERSION=3.20
ARG BUNDLER_VERSION=2.6.6

# Load node from official build
FROM node:$NODE_VERSION-alpine AS node

# Defines base image which builder and final stage use
FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION AS base

# Copy node binaries from the official image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

ENV DIR=/usr/src/app

RUN apk add --update --no-cache \
    bash \
    coreutils \
    git \
    npm \
    nodejs \
    tzdata \
    && gem update --system

# for Bundler
ARG BUNDLER_VERSION
RUN echo "Bundler version ${BUNDLER_VERSION}"
RUN gem install bundler:$BUNDLER_VERSION

# for Yarn
RUN npm install -g corepack
RUN corepack enable

# installs the required gems
FROM base AS gems
RUN apk add --update build-base && gem update --system

COPY bin bin
COPY Gemfile Gemfile.lock ./
# .bundle/config contains the information required to access rubygems.pkg.github.com/epimorphics/
COPY .bundle/config /root/.bundle/config
RUN bundle config set --local without 'development test' \
    && bundle config set --local frozen 1 \
    && bundle install

# install the required node modules
FROM base AS npm
RUN apk add --update build-base && gem update --system

WORKDIR ${DIR}
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN yarn install --immutable

# runs build to compile assets
FROM base AS builder
RUN apk add --update build-base && gem update --system

WORKDIR ${DIR}
# Copy the builds from the previous stages
COPY --from=gems --chown=app /usr/local/bundle /usr/local/bundle
COPY --from=npm --chown=app ${DIR}/node_modules ./node_modules

# Copy the rest of the application code
COPY config.ru Gemfile Gemfile.lock Rakefile ./
COPY package.json yarn.lock vite.config.mts .yarnrc.yml ./
COPY .yarn .yarn
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
    bundle exec rake vite:build \
    && mkdir -m 777 ${DIR}/coverage \
    && mkdir -m 777 ${DIR}/log

# Start a new stage to minimise the final image size
FROM base

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
COPY entrypoint.sh "/app/entrypoint.sh"
ENTRYPOINT ["sh", "/app/entrypoint.sh"]
