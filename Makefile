DOCKER_PRIVATE_REPO ?= vimond-dockerv2-local.jfrog.io
NAME = $(DOCKER_PRIVATE_REPO)/micros-baseimage
VERSION = $(shell git describe --tags --always)


.PHONY: all build test tag_latest release

all: build

build:
	docker build  -t $(NAME):$(VERSION)  .
	docker build  -t $(NAME):alpine-$(VERSION)   -f Dockerfile.alpine .

test:
	docker run --rm $(NAME):$(VERSION) java -version
	docker run --rm $(NAME):alpine-$(VERSION) java -version

tag_latest:
	docker tag  $(NAME):$(VERSION) $(NAME):latest
	docker tag  $(NAME):alpine-$(VERSION) $(NAME):alpine-latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)
