# Variables
RELEASE_NAME ?= argo-cd
NAMESPACE ?= argocd

VALUES_FILE ?= chart/values.yaml
CHART_PATH ?= chart

CRD_VERSION ?= $(shell helm show chart argo/argo-cd --version $$(grep 'version:' $(CHART_PATH)/Chart.yaml | grep -v '^version:' | awk '{print $$2}') 2>/dev/null | grep '^appVersion:' | awk '{print $$2}')

CONTAINER_RUNNER ?= docker
WORKDIR ?= $(shell pwd)
UID := $(shell id -u)
GID := $(shell id -g)

DOCKER_RUN_BASE := $(CONTAINER_RUNNER) run --rm -v $(WORKDIR):/workdir -w /workdir -u $(UID):$(GID)
DOCKER_RUN_HELM_DOCS := $(CONTAINER_RUNNER) run --rm -v $(WORKDIR)/chart:/helm-chart -w /helm-chart -u $(UID):$(GID)

.PHONY: help
help:
	@echo "Usage:"
	@echo "  make install        - Install Argo CD in the cluster"
	@echo "  make upgrade        - Upgrade Argo CD release"
	@echo "  make uninstall      - Uninstall Argo CD release"
	@echo "  make install-crds   - Install Argo CD CRDs separately"
	@echo "  make uninstall-crds - Uninstall Argo CD CRDs"
	@echo "  make deps           - Update Helm chart dependencies"
	@echo "  make lint           - Lint the Helm chart"
	@echo "  make template       - Render Helm templates locally"
	@echo "  make yamllint       - Lint YAML files inside container"
	@echo "  make yamlfix        - Format YAML files inside container"
	@echo "  make helm-docs      - Generate Helm docs inside container"

## -------------------- Helm Chart Management --------------------

.PHONY: deps
deps:
	helm repo add argo https://argoproj.github.io/argo-helm
	helm dependency update $(CHART_PATH)

.PHONY: install
install: deps
	helm install $(RELEASE_NAME) $(CHART_PATH) \
		--namespace $(NAMESPACE) --create-namespace \
		--set crds.install=false \
		-f $(VALUES_FILE)

.PHONY: upgrade
upgrade: deps
	helm upgrade $(RELEASE_NAME) $(CHART_PATH) \
		--namespace $(NAMESPACE) \
		--set crds.install=false \
		-f $(VALUES_FILE)

.PHONY: install-crds
install-crds: deps
	@echo "Installing Argo CD CRDs from official repository (version: $(CRD_VERSION))..."
	kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=$(CRD_VERSION)"

.PHONY: uninstall
uninstall:
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE)

.PHONY: uninstall-crds
uninstall-crds:
	@echo "Uninstalling Argo CD CRDs (version: $(CRD_VERSION))..."
	kubectl delete -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=$(CRD_VERSION)"

.PHONY: lint
lint: deps
	helm lint $(CHART_PATH)

.PHONY: template
template: deps
	helm template $(RELEASE_NAME) \
		$(CHART_PATH) \
		-f $(VALUES_FILE)

## -------------------- Container-Based Tools --------------------

.PHONY: yamllint
yamllint:
	@echo "Running yamllint container..."
	$(DOCKER_RUN_BASE) cytopia/yamllint:latest .

.PHONY: yamlfix
yamlfix:
	@echo "Running yamlfix container..."
	$(DOCKER_RUN_BASE) otherguy/yamlfix:latest .

.PHONY: helm-docs
helm-docs:
	@echo "Running helm-docs container..."
	$(DOCKER_RUN_HELM_DOCS) jnorwood/helm-docs:latest .
