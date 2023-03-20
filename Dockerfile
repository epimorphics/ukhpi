ARG ALPINE_VERSION
ARG RUBY_VERSION

# Defines base image which builder and final stage use
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} as base
ARG BUNDLER_VERSION

RUN apk add --update \
    bash \
    coreutils \
    git \
    nodejs \
    tzdata \
    yarn \
    && rm -rf /var/cache/apk/* \
    && gem install bundler:$BUNDLER_VERSION \
    && bundle config --global frozen 1

FROM base as builder

RUN apk add --update build-base

WORKDIR /usr/src/app

COPY config.ru Gemfile Gemfile.lock Rakefile ./
COPY package.json babel.config.js postcss.config.js yarn.lock ./
COPY .bundle/config /root/.bundle/config
COPY bin bin

RUN ./bin/bundle config set --local without 'development test' && ./bin/bundle install && mkdir log

COPY app app
COPY config config
COPY lib lib
COPY public public

# Compile
RUN yarn install --production && RAILS_ENV=production bundle exec rake assets:precompile \
  && mkdir -m 777 /usr/src/app/coverage

# Start a new build stage to minimise the final image size
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

WORKDIR /usr/src/app

COPY --from=builder --chown=app /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=app /usr/src/app .

USER app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh "/app/entrypoint.sh"
ENTRYPOINT ["sh", "/app/entrypoint.sh"]
