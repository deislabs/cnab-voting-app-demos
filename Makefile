SHELL             ?= bash
DOCKER_REGISTRY   ?= $(USER)
IMAGE_TAG         ?= latest
BUNDLE            ?= example-voting-app
BUNDLE_VERSION    ?= 0.1.0
BUNDLE_ARTIFACT   ?= $(BUNDLE)-$(BUNDLE_VERSION).tgz
STORAGE_CONTAINER ?= cnab-bundles

build: docker-build sign
push: docker-push

docker-build:
	docker build -t $(DOCKER_REGISTRY)/$(BUNDLE):$(IMAGE_TAG) $(BUNDLE)/cnab
	@sed -i 's;cnab/$(BUNDLE):latest;$(DOCKER_REGISTRY)/$(BUNDLE):latest;g' $(BUNDLE)/bundle.json

docker-push:
	docker push $(DOCKER_REGISTRY)/$(BUNDLE):$(IMAGE_TAG)

init:
	duffle init -u "test@cnab-voting-app-demos.com"

sign:
	duffle bundle sign -f $(BUNDLE)/bundle.json -o $(BUNDLE)/bundle.cnab

populate-creds:
	@sed 's;PATH/TO/KUBECONFIG;$(KUBECONFIG);g' $(BUNDLE)/example-creds.yaml > /tmp/$(BUNDLE)-creds.yaml

install: populate-creds
	duffle install $(BUNDLE) -f $(BUNDLE)/bundle.cnab -c /tmp/$(BUNDLE)-creds.yaml

uninstall:
	duffle uninstall $(BUNDLE) -c /tmp/$(BUNDLE)-creds.yaml

status:
	duffle status $(BUNDLE) -c /tmp/$(BUNDLE)-creds.yaml

upgrade:
	duffle upgrade $(BUNDLE) -c /tmp/$(BUNDLE)-creds.yaml

export:
	duffle export $(BUNDLE)

import:
	duffle import $(BUNDLE_ARTIFACT)

upload:
	az storage blob upload \
		-f $(BUNDLE_ARTIFACT) \
		-c $(STORAGE_CONTAINER) \
		-n $(BUNDLE_ARTIFACT)

