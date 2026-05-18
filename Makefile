.PHONY: all auth help image name publish tag vars version

ALPINE_VERSION?=3.23
BUNDLER_VERSION?=$(shell tail -1 Gemfile.lock | tr -d ' ')
NODE_VERSION?=$(shell cat .nvmrc)
RUBY_VERSION?=$(shell cat .ruby-version)

ACCOUNT?=$(shell aws sts get-caller-identity | jq -r .Account)
AWS_REGION?=eu-west-1
ECR?=${ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
GPR_OWNER?=epimorphics
APP_NAME?=$(shell awk -F: '$$1=="name" {print $$2}' deployment.yaml | sed -e 's/[[:blank:]]//g')
PAT?=$(shell read -p 'Github access token:' TOKEN; echo $$TOKEN)

SHORTNAME?=$(shell echo ${APP_NAME} | cut -f2 -d/)
STAGE?=dev
RAILS_RELATIVE_URL_ROOT?=/app/ukhpi

BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
COMMIT=$(shell git rev-parse --short HEAD)
VERSION?=$(shell /usr/bin/env ruby -e 'require "./app/lib/version" ; puts Version::VERSION')
TAG?=$(shell printf '%s_%s_%08d' ${VERSION} ${COMMIT} ${GITHUB_RUN_NUMBER})

IMAGE?=${APP_NAME}/${STAGE}
REPO?=${ECR}/${IMAGE}

BUNDLE_CFG=.bundle/config
BUNDLE=./bin/bundle
GITHUB_TOKEN=.github-token

${BUNDLE_CFG}: ${GITHUB_TOKEN}
	@${BUNDLE} config set --local rubygems.pkg.github.com ${GPR_OWNER}:`cat ${GITHUB_TOKEN}`

${GITHUB_TOKEN}:
	@echo ${PAT} > ${GITHUB_TOKEN}

all: image ## Default target: build the Docker image

auth: ${GITHUB_TOKEN} ${BUNDLE_CFG} ## Set up authentication for GitHub and Bundler
	@echo "Authentication set up for GitHub and Bundler."

help: ## Display this message
	@echo "Available make targets:"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'
	@echo ""
ifdef AWS_PROFILE
	@echo "Environment variables (optional: all variables have defaults):"
	@make vars
else
	@echo "Warning: AWS_PROFILE is not set. AWS CLI commands may fail."
	@echo "Re-run with AWS_PROFILE set to see all variables."
endif

image: auth ## Build the Docker image
	@echo Building ${APP_NAME}:${TAG} ...
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
		--build-arg image_name=${APP_NAME} \
		--tag ${APP_NAME}:${TAG} \
		.
	@echo Done.

name: ## Display the shortname of the application
	@echo ${SHORTNAME}

publish: image ## Publish the Docker image to the registry
	@echo Publishing image: ${REPO}:${TAG} ...
	@docker tag ${APP_NAME}:${TAG} ${REPO}:${TAG} 2>&1
	@docker push ${REPO}:${TAG} 2>&1
	@echo Done.

tag: ## Display the Docker image tag
	@echo ${TAG}

vars: ## Display build environment variables
	@echo "Docker: ${REPO}:${TAG}"
	@echo "ACCOUNT = ${ACCOUNT}"
	@echo "ALPINE_VERSION = ${ALPINE_VERSION}"
	@echo "AWS_REGION = ${AWS_REGION}"
	@echo "BUNDLER_VERSION = ${BUNDLER_VERSION}"
	@echo "COMMIT = ${COMMIT}"
	@echo "ECR = ${ECR}"
	@echo "GPR_OWNER = ${GPR_OWNER}"
	@echo "APP_NAME = ${APP_NAME}"
	@echo "NODE_VERSION = ${NODE_VERSION}"
	@echo "RAILS_RELATIVE_URL_ROOT = ${RAILS_RELATIVE_URL_ROOT}"
	@echo "REPO = ${REPO}"
	@echo "RUBY_VERSION = ${RUBY_VERSION}"
	@echo "SHORTNAME = ${SHORTNAME}"
	@echo "STAGE = ${STAGE}"
	@echo "TAG = ${TAG}"
	@echo "VERSION = ${VERSION}"

version: ## Display the application version
	@echo ${VERSION}
