.PHONY:	assets auth check clean image lint publish realclean run tag test vars

ACCOUNT?=$(shell aws sts get-caller-identity | jq -r .Account)
ALPINE_VERSION?=3.22
AWS_REGION?=eu-west-1
BUNDLER_VERSION?=$(shell tail -1 Gemfile.lock | tr -d ' ')
ECR?=${ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
GPR_OWNER?=epimorphics
NAME?=$(shell awk -F: '$$1=="name" {print $$2}' deployment.yaml | sed -e 's/[[:blank:]]//g')
PAT?=$(shell read -p 'Github access token:' TOKEN; echo $$TOKEN)
PORT?=3002
RUBY_VERSION?=$(shell cat .ruby-version)
NODE_VERSION?=$(shell cat .nvmrc)
SHORTNAME?=$(shell echo ${NAME} | cut -f2 -d/)
STAGE?=dev
API_SERVICE_URL?=http://localhost:8888
RAILS_RELATIVE_URL_ROOT?=/app/ukhpi
RUN_VARS?=-p


BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
COMMIT=$(shell git rev-parse --short HEAD)
VERSION?=$(shell /usr/bin/env ruby -e 'require "./app/lib/version" ; puts Version::VERSION')
TAG?=$(shell printf '%s_%s_%08d' ${VERSION} ${COMMIT} ${GITHUB_RUN_NUMBER})

IMAGE?=${NAME}/${STAGE}
REPO?=${ECR}/${IMAGE}

GITHUB_TOKEN=.github-token
BUNDLE_CFG=.bundle/config
BUNDLE=./bin/bundle
RAILS=./bin/rails

${BUNDLE_CFG}: ${GITHUB_TOKEN}
	@${BUNDLE} config set --local rubygems.pkg.github.com ${GPR_OWNER}:`cat ${GITHUB_TOKEN}`

${GITHUB_TOKEN}:
	@echo ${PAT} > ${GITHUB_TOKEN}

all: image

assets:
	@echo "Installing bundled gems ..."
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
	@echo "Cleaning up ${SHORTNAME} files..."
# Clean up the project
	@[ -d public/assets ] && ${RAILS} assets:clobber || :
# Clear cache files from tmp/
	@${RAILS} tmp:cache:clear
# Remove temporary files and directories
	@@ rm -rf bundle coverage log node_modules tmp

forceclean:
# Remove all bundled files
	@${BUNDLE} clean --force

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

forceclean: realclean
# Remove all bundled files
	@${BUNDLE} clean --force || :

lint: assets
	@${BUNDLE} exec rubocop

locations:
	@echo "Generating new UKHPI location files ... "
	@${RAILS} ukhpi:locations
	@echo "Done."

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

run: start
	@if docker network inspect dnet > /dev/null 2>&1; then echo "Using docker network dnet"; else echo "Create docker network dnet"; Docker network create dnet; sleep 2; fi
	@docker run ${RUN_VARS} ${PORT}:3000 --env API_SERVICE_URL=${API_SERVICE_URL} --network dnet --rm --name ${SHORTNAME} ${NAME}:${TAG}

server: start
	@API_SERVICE_URL=${API_SERVICE_URL} ${RAILS} server -p ${PORT}

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
