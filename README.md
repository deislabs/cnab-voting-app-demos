CNAB Voting App Demos

Prerequisites:
 * Docker
 * Docker registry
 * Duffle
 * Kubernetes Cluster

TODO: update with details and/or commands to install prereqs

Example usage, here using a K8s-based [example-voting-app](./example-voting-app/README.md):

```
export KUBECONFIG=path/to/kubeconfig
export DOCKER_REGISTRY=mydockerregistry # if different from $(USER)
export BUNDLE=example-voting-app

# Build and sign BUNDLE
make build

# Push BUNDLE invocation image(s) to DOCKER_REGISTRY
make push

# Install BUNDLE
make install

# Check BUNDLE status
make status

# Upgrade BUNDLE
make upgrade

# (Re-)Check BUNDLE status
make status

# Uninstall BUNDLE
make uninstall
```
