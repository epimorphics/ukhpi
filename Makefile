.PHONY:	all assets auth bundles checks clean compiled eject forceclean help image lint locations modules name publish realclean run server start stop tag test test-assets vars version

ALPINE_VERSION?=3.22
BUNDLER_VERSION?=$(shell tail -1 Gemfile.lock | tr -d ' ')
NODE_VERSION?=$(shell cat .nvmrc)
RUBY_VERSION?=$(shell cat .ruby-version)

ACCOUNT?=$(shell aws sts get-caller-identity | jq -r .Account)
AWS_REGION?=eu-west-1
ECR?=${ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
GPR_OWNER?=epimorphics
NAME?=$(shell awk -F: '$$1=="name" {print $$2}' deployment.yaml | sed -e 's/[[:blank:]]//g')
PAT?=$(shell read -p 'Github access token:' TOKEN; echo $$TOKEN)
PORT?=3002

SHORTNAME?=$(shell echo ${NAME} | cut -f2 -d/)
STAGE?=dev
# Please pass in the API_SERVICE_URL from your command line or .env.development file
API_SERVICE_URL?=http://localhost:8888
RAILS_RELATIVE_URL_ROOT?=/app/ukhpi
RUN_VARS?=-p


BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
COMMIT=$(shell git rev-parse --short HEAD)
VERSION?=$(shell /usr/bin/env ruby -e 'require "./app/lib/version" ; puts Version::VERSION')
TAG?=$(shell printf '%s_%s_%08d' ${VERSION} ${COMMIT} ${GITHUB_RUN_NUMBER})

IMAGE?=${NAME}/${STAGE}
REPO?=${ECR}/${IMAGE}

BUNDLE_CFG=.bundle/config
BUNDLE=./bin/bundle
GITHUB_TOKEN=.github-token
RAILS=./bin/rails
VITE=./bin/vite

${BUNDLE_CFG}: ${GITHUB_TOKEN}
	@${BUNDLE} config set --local rubygems.pkg.github.com ${GPR_OWNER}:`cat ${GITHUB_TOKEN}`

${GITHUB_TOKEN}:
	@echo ${PAT} > ${GITHUB_TOKEN}

all: image

assets: bundles modules compiled
	@echo vite info
	@${RAILS} vite:info

auth: ${GITHUB_TOKEN} ${BUNDLE_CFG}
	@echo "Authentication set up for GitHub and Bundler."

bundles:
	@echo "Installing Ruby gems via Bundler..."
	@${BUNDLE} install

checks: lint test
	@echo "All checks passed."

clean:
	@echo "Cleaning up ${SHORTNAME} files..."
# Clean up the project
	@[ -d public/assets ] && ${RAILS} assets:clobber || :
# Clear cache files from tmp/
	@${RAILS} tmp:cache:clear
# Clean yarn cache
	@yarn cache clean
# Remove temporary files and directories
	@@ rm -rf bundle coverage log node_modules tmp
# Remove VCR cassettes to avoid using stale data
	@@ rm test/vcr_cassettes/* || :

compiled:
	@echo "Removing old compiled assets and compiling via vite ..."
	@NODE_OPTIONS=--openssl-legacy-provider ${RAILS} vite:clobber vite:build

eject:
	@echo "Removing VCR Cassettes to avoid stale data..."
	@rm -rf test/vcr_cassettes/

eslint:
	@echo "Running ESLint for ${SHORTNAME} ..."
# Lint JavaScript files with ESLint and auto-fix where possible
	@yarn lint

forceclean: realclean
# Remove all bundled files
	@${BUNDLE} clean --force || :

help:
	@echo "Make targets:"
	@echo "  all - build the Docker image (default)"
	@echo "  assets - install gems and yarn packages, compile assets"
	@echo "  auth - set up authentication for GitHub and Bundler"
	@echo "  bundles - install Ruby gems via Bundler"
	@echo "  checks - run all linting and tests as a single task"
	@echo "  clean - remove temporary files"
	@echo "  compiled - remove old compiled assets and compile via vite"
	@echo "  eject - remove vcr cassettes to avoid stale data"
	@echo "  eslint - run ESLint on JavaScript files"
	@echo "  forceclean - remove all generated files including bundled gems"
	@echo "  help - show this help message"
	@echo "  image - build the Docker image"
	@echo "  lint - run linters"
	@echo "  locations - generate new UKHPI location files"
	@echo "  modules - install node packages via yarn"
	@echo "  name - return the image name"
	@echo "  publish - release the image to the Docker registry"
	@echo "  realclean - remove all temporary files as well as authentication tokens"
	@echo "  rubocop - run RuboCop on Ruby files"
	@echo "  run - run the Docker image with Rails running"
	@echo "  server - start the Rails server using foreman"
	@echo "  start - start the Docker container"
	@echo "  stop - stop the Docker container"
	@echo "  tag - return a tag string for the current build"
	@echo "  test - run rails tests"
	@echo "  test-assets - rebuild assets and run rails tests"
	@echo "  vars - display all environment variables and their values"
	@echo "  version - show the current app version"
	@echo ""
	@echo "Environment variables (optional: all variables have defaults):"
	@echo "  ACCOUNT - AWS account ID for ECR (default: from aws cli)"
	@echo "  ALPINE_VERSION - version of Alpine Linux to use (default: from Dockerfile)"
	@echo "  AWS_REGION - AWS region for ECR (default: from aws cli)"
	@echo "  BUNDLER_VERSION - version of Bundler to use (default: from Gemfile.lock)"
	@echo "  ECR - URL of the ECR registry (default: from aws cli)"
	@echo "  GPR_OWNER - GitHub owner for the package registry (default: from git config)"
	@echo "  IMAGE - name of the Docker image (default: ${NAME}:${TAG})"
	@echo "  API_SERVICE_URL - URL of the FSA Data Dot Food API (default: ${API_SERVICE_URL})"
	@echo "  NAME - name of the Application (default: from deployment.yaml)"
	@echo "  NODE_VERSION - version of Node.js to use (default: from .nvmrc)"
	@echo "  PAT - GitHub personal access token (default: prompt)"
	@echo "  PORT - port to expose from the Docker container (default: 3000)"
	@echo "  RUBY_VERSION - version of Ruby to use (default: from .ruby-version)"
	@echo "  RAILS_RELATIVE_URL_ROOT - relative URL root (default: /catalog)"
	@echo "  RUN_VARS - additional docker run variables (default: -p)"
	@echo "  SHORTNAME - short name of the application (default: from NAME)"
	@echo "  STAGE - deployment stage (default: dev)"
	@echo "  TAG - tag to apply to the Docker image (default: VERSION_COMMIT_GITHUB_RUN_NUMBER)"
	@echo "  VERSION - version of the application (default: from VERSION file)"

image: auth
	@echo Building ${NAME}:${TAG} ...
	@docker build \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg RUBY_VERSION=${RUBY_VERSION} \
		--build-arg NODE_VERSION=${NODE_VERSION} \
		--build-arg BUNDLER_VERSION=${BUNDLER_VERSION} \
		--build-arg RAILS_RELATIVE_URL_ROOT=${RAILS_RELATIVE_URL_ROOT} \
		--build-arg VERSION=${VERSION} \
		--build-arg git_branch=${BRANCH} \
		--build-arg git_commit_hash=${COMMIT} \
		--build-arg github_run_number=${GITHUB_RUN_NUMBER} \
		--build-arg image_name=${NAME} \
		--tag ${NAME}:${TAG} \
		.
	@echo Done.

lint: rubocop eslint
	@echo "All linting complete."

locations:
	@echo "Generating new UKHPI location files ... "
	@${RAILS} ukhpi:locations
	@echo "Done."

modules:
	@echo "Installing node packages ..."
	@yarn install

name:
	@echo ${SHORTNAME}

publish: image
	@echo Publishing image: ${REPO}:${TAG} ...
	@docker tag ${NAME}:${TAG} ${REPO}:${TAG} 2>&1
	@docker push ${REPO}:${TAG} 2>&1
	@echo Done.

realclean: clean
	@echo "Removing authentication from ${SHORTNAME}..."
	@rm -f ${GITHUB_TOKEN} ${BUNDLE_CFG}

rubocop:
	@echo "Running RuboCop linting for ${SHORTNAME} ..."
# Auto-correct offenses safely where possible with the `-a` flag
	@${BUNDLE} exec rubocop -a

run: start
	@if docker network inspect dnet > /dev/null 2>&1; then echo "Using docker network dnet"; else echo "Create docker network dnet"; docker network create dnet; sleep 2; fi
	@docker run ${RUN_VARS} ${PORT}:3000 --env API_SERVICE_URL=${API_SERVICE_URL} --network dnet --rm --name ${SHORTNAME} ${NAME}:${TAG}

server: start
ifdef DEBUG
	@echo "Starting Rails server in debug mode...";
	@echo "Remember to start foreman without the web process: ";
	@echo "foreman start -f Procfile.dev -e .env.local,.env.development web=0,all=1";
	@${RAILS} server -p ${PORT} -b 0.0.0.0;
else
	@echo "Starting Rails server in standard mode...";
	@echo "If you need use the debugger gem, stop the server and use \`DEBUG=true make server\` instead";
	@exec foreman start -f Procfile.dev -e .env.local,.env.development --color
endif

start: stop
	@echo "Starting ${SHORTNAME} pointing to ${API_SERVICE_URL} API ..."

stop:
	@echo "Stopping ${SHORTNAME} ..."
	@docker stop ${SHORTNAME} > /dev/null 2>&1 || :

tag:
	@echo ${TAG}

test:
	@echo "Running unit tests ..."
	@${RAILS} test

test-assets:
	@echo "Running unit tests with assets rebuilt..."
	@${VITE} build --clobber --mode=test
	@${RAILS} test

vars:
	@echo "Docker: ${REPO}:${TAG}"
	@echo "ACCOUNT = ${ACCOUNT}"
	@echo "ALPINE_VERSION = ${ALPINE_VERSION}"
	@echo "AWS_REGION = ${AWS_REGION}"
	@echo "BUNDLER_VERSION = ${BUNDLER_VERSION}"
	@echo "ECR = ${ECR}"
	@echo "GPR_OWNER = ${GPR_OWNER}"
	@echo "NAME = ${NAME}"
	@echo "RAILS_RELATIVE_URL_ROOT = ${RAILS_RELATIVE_URL_ROOT}"
	@echo "RUBY_VERSION = ${RUBY_VERSION}"
	@echo "NODE_VERSION = ${NODE_VERSION}"
	@echo "SHORTNAME = ${SHORTNAME}"
	@echo "STAGE = ${STAGE}"
	@echo "COMMIT = ${COMMIT}"
	@echo "REPO = ${REPO}"
	@echo "TAG = ${TAG}"
	@echo "VERSION = ${VERSION}"

version:
	@echo ${VERSION}
