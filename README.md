# Argo-cd Deployment

Helm chart for deploying Argo CD in a Kubernetes cluster.

## Purpose

This repository provides a modular Helm-based deployment for Argo CD, using the official Helm chart from [argo-helm](https://github.com/argoproj/argo-helm) as a dependency. It focuses strictly on installing and configuring the Argo CD control plane and is intended to be environment-agnostic, easy to version and maintain.

It also combines the Helm chart with a Makefile to simplify and standardize deployment tasks. The Makefile automates common Helm operations (install, upgrade, uninstall, dependencies, linting) and YAML quality checks, making the deployment process faster, less error-prone, and easier to maintain across environments.

## Structure

- `chart/`: Helm chart directory containing Helm resources:
    - `templates/`: Additional Argo CD manifest files (if needed).
    - `values.yaml`: Base configuration for the Argo CD deployment.
    - `Chart.yaml`: Helm chart metadata and dependency declaration.
- `Makefile`: Simplifies common Helm and YAML operations with convenient commands.

## Installation (via Helm)

```bash
git clone https://github.com/SimonaCatanoiu/argocd-k8s-deployment.git
cd argocd-k8s-deployment

# Install Argo CD
make install
```

## Using the Makefile

The `Makefile` provides several convenient commands to manage Argo CD deployments and Helm chart.

### 🔧 Variables

These variables can be overridden via environment variables or `make` arguments:

```makefile
RELEASE_NAME ?= argo-cd
NAMESPACE ?= argocd
VALUES_FILE ?= chart/values.yaml
CHART_PATH ?= chart
CONTAINER_RUNNER ?= docker
WORKDIR ?= $(shell pwd)
```

### 📦 Available Commands

| Command       | Description                                                      |
|---------------|------------------------------------------------------------------|
| `make help`        | Show available commands                                        |
| `make deps`        | Update Helm chart dependencies                                |
| `make install`     | Install Argo CD with the configured values                    |
| `make upgrade`     | Upgrade an existing Argo CD release                            |
| `make uninstall`   | Uninstall the Argo CD release                                  |
| `make lint`        | Lint the Helm chart                                            |
| `make template`    | Render Helm templates locally (dry-run)                        |
| `make yamllint`    | Lint YAML files using a containerized yamllint tool           |
| `make yamlfix`     | Format YAML files using a containerized yamlfix tool          |
| `make helm-docs`   | Generate Helm chart documentation inside a container          |

### 💡 Example usage

```bash
make install
make upgrade NAMESPACE=argocd VALUES_FILE=chart/values.yaml
make yamllint
make yamlfix
```

## Notes

- This repository **does not** contain any `Application` or `ApplicationSet` resources.
- This repository requires Docker to be installed. The `Makefile` leverages containerized tools (`yamllint`, `yamlfix`, `helm-docs`) to avoid local environment dependencies.
