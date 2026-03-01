# Phase 5 — Install Helm

Run on **k01m1**:

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm version
```

!!! info "What is Helm?"
    Helm is the package manager for Kubernetes. It uses **charts** — pre-packaged collections of Kubernetes manifests — to install applications. We need it to install cert-manager and Rancher.
