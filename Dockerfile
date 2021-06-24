ARG RUBY_VERSION=2.6.6

# Defining ruby version
FROM ruby:$RUBY_VERSION-alpine

# Set working dir and copy app
WORKDIR /usr/src/app
COPY . .

# Prerequisites for gems install
RUN apk add build-base \
            npm \
            tzdata \
            git

ARG BUNDLER_VERSION=2.1.4

# Install bundler and yarn
RUN gem install bundler:$BUNDLER_VERSION
RUN npm install -g yarn

# Install gems and yarn dependencies
RUN bundle install
RUN yarn install

# Params
ARG RAILS_ENV="production"
# Set environment variables and expose the running port
ENV RAILS_ENV=$RAILS_ENV
ENV RAILS_ENV="production"
EXPOSE 3000

# Add secrets as environment variables (used development env key temporarily)
ENV SECRET_KEY_BASE="a98f0b0b2c66a4d685719afad3a931d9d19e3b10f5fd61978ee56e456b0430a18b8890d69c830a39f942f826e7c47749235d7727f734cde7887af8f2f76c7ec4" 

# Add app entrypoint script
ENTRYPOINT [ "sh", "./entrypoint.sh" ]