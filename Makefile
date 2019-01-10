DOCKER_REGISTRY ?= $(USER)
IMAGE_TAG       ?= latest
BUNDLE          ?=

build: docker-build sign
push: docker-push

docker-build:
ifndef BUNDLE
	$(call docker-all,docker-build)
else 
	docker build -t $(DOCKER_REGISTRY)/$(BUNDLE):$(IMAGE_TAG) $(BUNDLE)/cnab
	sed -i 's;cnab/$(BUNDLE):latest;$(DOCKER_REGISTRY)/$(BUNDLE):latest;g' $(BUNDLE)/bundle.json
endif

docker-push:
ifndef BUNDLE
	$(call docker-all,docker-push)
else
	docker push $(DOCKER_REGISTRY)/$(BUNDLE):$(IMAGE_TAG)
endif

sign:
ifndef BUNDLE
	$(call bundle-all,sign)
else
	duffle bundle sign -f $(BUNDLE)/bundle.json -o $(BUNDLE)/bundle.cnab
endif

populate-creds:
ifndef BUNDLE
	$(call bundle-all,populate-creds)
else
	sed 's;PATH/TO/KUBECONFIG;$(KUBECONFIG);g' $(BUNDLE)/example-creds.yaml > /tmp/$(BUNDLE)-creds.yaml
endif

install: populate-creds
ifndef BUNDLE
	$(call bundle-all,install)
else
	duffle install $(BUNDLE) -f $(BUNDLE)/bundle.cnab -c /tmp/$(BUNDLE)-creds.yaml
endif

uninstall:
ifndef BUNDLE
	$(call bundle-all,uninstall)
else
	duffle uninstall $(BUNDLE) -c /tmp/$(BUNDLE)-creds.yaml
endif

status:
ifndef BUNDLE
	$(call bundle-all,status)
else
	duffle status $(BUNDLE) -c /tmp/$(BUNDLE)-creds.yaml
endif

upgrade:
ifndef BUNDLE
	$(call bundle-all,upgrade)
else
	duffle upgrade $(BUNDLE) -c /tmp/$(BUNDLE)-creds.yaml
endif

# Helpers

# all loops through all sub-directories and if the file provided by the first argument exists,
# it will run the make target(s) provided by the second argument
define all
	@for dir in $$(ls -1); do \
		if [[ -e "$$dir/$(1)" ]]; then \
			BUNDLE=$$dir make --no-print-directory $(2) ; \
		fi ; \
	done
endef

# run the provided make target on all bundles with a 'cnab/Dockerfile' file in their directory
define docker-all
	$(call all,cnab/Dockerfile,$(1))
endef

# run the provided make target on all bundles with a 'bundle.json' file in their directory
define bundle-all
	$(call all,bundle.json,$(1))
endef