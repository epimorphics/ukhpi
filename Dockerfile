# Defining ruby version
FROM ruby:2.6.6-alpine

# Copy app and set working dir
COPY . /application
WORKDIR /application

# Prerequisites for gems install
RUN rm -rf /application/Gemfile.lock
RUN apk add build-base \
            npm \
            tzdata \
            git

# Install bundler and yarn
RUN gem install bundler:2.1.4
RUN npm install -g yarn

# Install gems and yarn dependencies
RUN bundle install --without="development"
RUN yarn install

# Set environment variables and expose the running port
ENV RELATIVE_URL_ROOT="/"
ENV RAILS_ENV="production"
EXPOSE 3000

# Add secrets as environment variables (used development env key temporarily)
ENV SECRET_KEY_BASE="a98f0b0b2c66a4d685719afad3a931d9d19e3b10f5fd61978ee56e456b0430a18b8890d69c830a39f942f826e7c47749235d7727f734cde7887af8f2f76c7ec4" 

# Add app entrypoint script
ENTRYPOINT [ "sh", "./entrypoint.sh" ]