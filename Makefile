.PHONY:	clean image release prod tag test help version

APP ?= ukhpi
REGISTRY ?=  173681544495.dkr.ecr.eu-west-1.amazonaws.com/epimorphics
IMAGE ?= ${APP}
API_SERVICE_URL ?= http://localhost:8080/dsapi

ifeq ($(origin SECRET_KEY_BASE), undefined)
SECRET_KEY_BASE != rails secret
endif

APP_VERSION != ruby -I . -e 'require "app/lib/version" ; puts Version::VERSION'

RUBY_VERSION != cut -d '.' -f 1,2 .ruby-version

BUNDLER_VERSION != bundler -v | cut -d ' ' -f 3

all: test release

version:
	@echo App version is ${APP_VERSION}
	@echo Ruby version is ${RUBY_VERSION}
	@echo Bundler version is ${BUNDLER_VERSION}

image:
	docker build \
	  --build-arg APP_VERSION=${APP_VERSION} \
		--build-arg RUBY_VERSION=${RUBY_VERSION} \
		--build-arg BUNDLER_VERSION=${BUNDLER_VERSION} \
		--tag ${IMAGE}:${APP_VERSION} \
		.

prod: image
	docker run --network=host --rm --name ${APP} -e RAILS_ENV=production -e API_SERVICE_URL=${API_SERVICE_URL} -e SECRET_KEY_BASE=${SECRET_KEY_BASE} ${IMAGE}:${APP_VERSION}

test: image
	@-docker stop ${APP} 2> /dev/null || true
	@docker run -d --rm --name ${APP} --network=host -e API_SERVICE_URL=${API_SERVICE_URL} -e RAILS_ENV=development ${IMAGE}:${APP_VERSION}
	@docker exec -it -e API_SERVICE_URL=${API_SERVICE_URL} -e RAILS_ENV=test ${APP} ./bin/rails test
	@docker stop ${APP}

tag: image
	@docker tag ${IMAGE}:${APP_VERSION} ${REGISTRY}/${IMAGE}:${APP_VERSION}

release: tag
	@docker push ${REGISTRY}/${IMAGE}:${APP_VERSION}

clean:
	@rake assets:clobber webpacker:clobber tmp:clear

help:
	@echo "Make targets:"
	@echo "  prod - run the Docker image with Rails running in production mode"
	@echo "  test - run rails test in the container"
	@echo "  tag - tag the image with the REGISTRY, in preparation for release"
	@echo "  release - push the image to the Docker registry"
	@echo "  clean - remove temporary files"
	@echo "  version - show the current app version"
	@echo ""
	@echo "Environment variables (optional: all variables have defaults):"
	@echo "  PREFIX"
	@echo "  IMAGE"
	@echo "  API_SERVICE_URL"
	@echo "  SECRET_KEY_BASE"
	@echo "  APP_VERSION"
	@echo "  RUBY_VERSION"
	@echo "  BUNDLER_VERSION"
