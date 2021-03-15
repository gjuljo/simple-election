################################################################################
# Variables
################################################################################
CGO := 0

# Most likely want to override these when calling `make image`
REG ?= registry.lvh.me:5000
IMAGE ?= gjuljo/election
TAG ?= latest
PREFIX_IMAGE := $(REG)/$(IMAGE)
NAMESPACE := default
APP_NAME := election

.PHONY: help
help:
	@echo "------------------------------------------------------------HELP------------------------------------------------------------------"
	@echo "make fmt                                                  - format code"
	@echo "make build                                                - compile both eventstore and eventsink code"
	@echo "make images REG=<reg> IMAGE=<repo> TAG=<tag>              - build docker images for eventstore and sink"
	@echo "make push REG=<reg> IMAGE=<repo> TAG=<tag>                - push all tags of eventstore docker image <reg>/<repo>:<tag>"
	@echo "make run                                                  - starts the app with hot reload"
	@echo "make intall                                               - creates namespace if missing, replaces the image on k3d local cluster"
	@echo "---------------------------------------------------------------------------------------------------------------------------------"
	
################################################################################
# Format code
################################################################################
.PHONY: fmt
fmt:
	find . -name '*.go' | grep -v vendor | xargs gofmt -s -w


################################################################################
# Download app dependencies
################################################################################
.PHONY: deps
deps:
	go mod download

################################################################################
# Compile app
################################################################################
.PHONY: build

build: deps
	go build -a -installsuffix cgo -ldflags="-w -s -X main.BUILDDATE=`date +%Y-%m-%dT%T%z`" -o bin/testelection main.go


################################################################################
# Build Docker image
################################################################################
.PHONY: images

images:
	docker build \
 	--build-arg VERSION="$(VERSION)" \
	--build-arg BUILD_INFO="$(BUILD_INFO)" \
	--build-arg http_proxy="$(http_proxy)" \
	--build-arg https_proxy="$(https_proxy)"  \
	--build-arg HTTP_PROXY="$(HTTP_PROXY)"  \
	--build-arg HTTPS_PROXY="$(HTTPS_PROXY)"  \
	--build-arg NO_PROXY="$(NO_PROXY)"  \
	--build-arg no_proxy="$(no_proxy)"  \
	-t $(PREFIX_IMAGE):$(TAG) $(OPTIONS) \
    -f Dockerfile .

################################################################################
# Push Docker image
################################################################################
.PHONY: push

push:
	docker push $(PREFIX_IMAGE):$(TAG)

################################################################################
# Run locally
################################################################################
.PHONY: run
run:
	air -c .air.toml

################################################################################
# Deploy on local k3d
################################################################################
.PHONY: install
install:
	-kubectl create ns $(NAMESPACE)
	-helm uninstall -n $(NAMESPACE) $(APP_NAME)
	helm install -n $(NAMESPACE) $(APP_NAME) chart


################################################################################
# Uninstall from local k3d
################################################################################
.PHONY: uninstall
uninstall:
	-helm uninstall -n $(NAMESPACE) $(APP_NAME)
