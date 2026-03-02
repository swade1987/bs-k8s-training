# Install the Flux Operator

The Flux Operator manages the lifecycle of Flux controllers on your cluster. Install it once, then everything else is managed through Git.

---

## Why the Operator Approach?

There are two ways to install Flux:

| Approach | How | Best For |
|----------|-----|----------|
| `flux bootstrap` CLI | Imperative command, pushes manifests to Git | Quick start, single cluster |
| **Flux Operator** | Helm install + declarative FluxInstance resource | Production, multi-cluster, IaC |

We're using the **Operator approach** because:

- It's fully declarative — the FluxInstance is a Kubernetes resource you version in Git
- It manages upgrades automatically (including itself) with cosign verification
- It works with Helm, Terraform, and other IaC tools
- It fits naturally with Rancher's multi-cluster model

---

## Prerequisites

### Install the Flux CLI

You'll need the `flux` CLI for creating secrets and checking status.

=== "macOS (Homebrew)"

    ```bash
    brew install fluxcd/tap/flux
    ```

=== "Linux"

    ```bash
    curl -s https://fluxcd.io/install.sh | sudo bash
    ```

=== "Windows (Chocolatey)"

    ```powershell
    choco install flux
    ```

### Verify cluster compatibility

Make sure your `KUBECONFIG` is pointing to **your** downstream cluster (not the management cluster):

```bash
# Check you're on the right cluster
kubectl config current-context
kubectl get nodes

# Check Flux compatibility
flux check --pre
```

---

## Install via Helm

```bash
helm install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --namespace flux-system \
  --create-namespace \
  --wait
```

---

## Verify

```bash
kubectl get pods -n flux-system
```

You should see the `flux-operator` pod running:

```
NAME                              READY   STATUS    RESTARTS   AGE
flux-operator-xxxxxxxxxx-xxxxx    1/1     Running   0          30s
```

!!! info "What just happened?"
    The Flux Operator is running, but **Flux itself is not installed yet.** The operator is waiting for a FluxInstance resource to tell it what to deploy. That's the next step.

---

## What's Running Now

```
Your Cluster
┌──────────────────────────────────────┐
│  flux-system namespace               │
│                                      │
│  ┌────────────────────┐              │
│  │  flux-operator     │ ← Watching   │
│  │  (1 pod)           │   for a      │
│  └────────────────────┘   FluxInstance│
│                                      │
│  Nothing else yet...                 │
└──────────────────────────────────────┘
```

Next: [Create a FluxInstance →](create-instance.md)
