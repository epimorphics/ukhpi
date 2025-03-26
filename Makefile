.PHONY:	assets check clean image lint publish realclean run tag test vars

ACCOUNT?=$(shell aws sts get-caller-identity | jq -r .Account)
ALPINE_VERSION?=3.20
AWS_REGION?=eu-west-1
BUNDLER_VERSION?=$(shell tail -1 Gemfile.lock | tr -d ' ')
ECR?=${ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
GPR_OWNER?=epimorphics
NAME?=$(shell awk -F: '$$1=="name" {print $$2}' deployment.yaml | sed -e 's/[[:blank:]]//g')
PAT?=$(shell read -p 'Github access token:' TOKEN; echo $$TOKEN)
PORT?=3002
RUBY_VERSION?=$(shell cat .ruby-version)
SHORTNAME?=$(shell echo ${NAME} | cut -f2 -d/)
STAGE?=dev
API_SERVICE_URL?=http://data-api:8080

BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
COMMIT=$(shell git rev-parse --short HEAD)
VERSION?=$(shell /usr/bin/env ruby -e 'require "./app/lib/version" ; puts Version::VERSION')
TAG?=$(shell printf '%s_%s_%08d' ${VERSION} ${COMMIT} ${GITHUB_RUN_NUMBER})

${TAG}:
	@echo ${TAG}

IMAGE?=${NAME}/${STAGE}
REPO?=${ECR}/${IMAGE}

GITHUB_TOKEN=.github-token
BUNDLE_CFG=.bundle/config
BUNDLE=./bin/bundle
RAILS=./bin/rails

all: image

${BUNDLE_CFG}: ${GITHUB_TOKEN}
	@${BUNDLE} install config set --local rubygems.pkg.github.com ${GPR_OWNER}:`cat ${GITHUB_TOKEN}`

${GITHUB_TOKEN}:
	@echo ${PAT} > ${GITHUB_TOKEN}

assets:
	@echo "Installing bundler packages ..."
	@${BUNDLE} install
	@echo "Installing yarn packages ..."
	@yarn install
	@echo "Removing old compiled assets and compiling via vite ..."
	@NODE_OPTIONS=--openssl-legacy-provider ${RAILS} vite:clobber vite:build
	@echo vite info
	@${RAILS} vite:info

auth: ${GITHUB_TOKEN} ${BUNDLE_CFG}

check: lint test
	@echo "All checks passed."

clean:
# Add a marker to the Gemfile
	@sed -i -e 's/^/##~## /' Gemfile
# Remove all assets
	[ -d public/vite/assets ] && ${RAILS} vite:clobber || :
# Clear cache files from tmp/
	@${RAILS} tmp:cache:clear
# Remove all bundled files
	@${BUNDLE} clean --force
# Remove all generated files
	@rm -rf vendor bundle coverage log node_modules Gemfile.lock
# Remove the marker from the Gemfile
	@sed -i -e 's/^##~## //' Gemfile

image: auth
	@echo Building ${NAME}:${TAG} ...
	@docker build \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg RUBY_VERSION=${RUBY_VERSION} \
		--build-arg BUNDLER_VERSION=${BUNDLER_VERSION} \
		--build-arg VERSION=${VERSION} \
		--build-arg git_branch=${BRANCH} \
		--build-arg git_commit_hash=${COMMIT} \
		--build-arg github_run_number=${GITHUB_RUN_NUMBER} \
		--build-arg image_name=${NAME} \
		--tag ${NAME}:${TAG} \
		.
	@echo Done.

lint: assets
	@${BUNDLE} install exec rubocop

locations:
	@echo "Generating new UKHPI location files ... "
	@${RAILS} ukhpi:locations
	@echo "Done."

publish: image
	@echo Publishing image: ${REPO}:${TAG} ...
	@docker tag ${NAME}:${TAG} ${REPO}:${TAG} 2>&1
	@docker push ${REPO}:${TAG} 2>&1
	@echo Done.

realclean: clean
# Clear github token from bundle config
	@rm -f ${GITHUB_TOKEN} ${BUNDLE_CFG}

run: start
	@if docker network inspect dnet > /dev/null 2>&1; then echo "Using docker network dnet"; else echo "Create docker network dnet"; docker network create dnet; sleep 2; fi
	@docker run -p ${PORT}:3000 -e API_SERVICE_URL=${API_SERVICE_URL} --network dnet --rm --name ${SHORTNAME} ${NAME}:${TAG}

secret:
	@echo "Creating secret ..."
	@export SECRET_KEY_BASE=$(./bin/rails secret)

server:
	@echo "Starting local server ..."
	@API_SERVICE_URL=${API_SERVICE_URL} ./bin/rails server -p ${PORT}

start:
	@docker stop ${SHORTNAME} > /dev/null 2>&1 || :
	@echo "Starting ${SHORTNAME} ..."

tag:
	@echo ${TAG}

test: assets
	@echo "Running unit tests ..."
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
	@echo "RUBY_VERSION = ${RUBY_VERSION}"
	@echo "SHORTNAME = ${SHORTNAME}"
	@echo "STAGE = ${STAGE}"
	@echo "COMMIT = ${COMMIT}"
	@echo "REPO = ${REPO}"
	@echo "TAG = ${TAG}"
	@echo "VERSION = ${VERSION}"
