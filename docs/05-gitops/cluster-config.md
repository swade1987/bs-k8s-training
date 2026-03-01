# Cluster Configuration

Flux is running and syncing from Git. Now let's configure three things that make it production-ready: cluster identity, automated upgrades, and commit status notifications.

**All of these changes are made in Git. Flux applies them automatically.**

---

## 1. Cluster Runtime Info

To identify which cluster Flux is running on — useful when managing multiple clusters from the same repo.

Create `clusters/training/flux-system/flux-runtime-info.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: flux-runtime-info
  namespace: flux-system
  labels:
    toolkit.fluxcd.io/runtime: "true"
data:
  ENVIRONMENT: training
  CLUSTER_NAME: lab-XX
  CLUSTER_DOMAIN: training.k.ma-no.si
```

!!! tip "Replace XX with your lab number"
    For example, Lab 04 (Damir) would set `CLUSTER_NAME: lab-04`.

Commit and push:

```bash
git add -A
git commit -m "Add cluster runtime info"
git push origin main
```

---

## 2. Automated Operator Upgrades

This is where it gets interesting. We're going to tell Flux to **manage its own operator upgrades** — the operator that manages Flux. Fully self-managing.

Create `clusters/training/flux-system/flux-operator.yaml`:

```yaml
apiVersion: fluxcd.controlplane.io/v1
kind: ResourceSet
metadata:
  name: flux-operator
  namespace: flux-system
spec:
  dependsOn:
    - apiVersion: apiextensions.k8s.io/v1
      kind: CustomResourceDefinition
      name: helmreleases.helm.toolkit.fluxcd.io
  resources:
    - apiVersion: source.toolkit.fluxcd.io/v1beta2
      kind: OCIRepository
      metadata:
        name: flux-operator
        namespace: flux-system
      spec:
        interval: 30m
        url: oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator
        ref:
          semver: '*'
        verify:
          provider: cosign
          matchOIDCIdentity:
          - issuer: ^https://token\.actions\.githubusercontent\.com$
            subject: ^https://github\.com/controlplaneio-fluxcd/charts/.*$
    - apiVersion: helm.toolkit.fluxcd.io/v2
      kind: HelmRelease
      metadata:
        name: flux-operator
        namespace: flux-system
      spec:
        interval: 30m
        releaseName: flux-operator
        serviceAccountName: flux-operator
        chartRef:
          kind: OCIRepository
          name: flux-operator
        values:
          multitenancy:
            enabled: true
            defaultServiceAccount: flux-operator
          reporting:
            interval: 45s
```

### What This Does

| Resource | Purpose |
|----------|---------|
| **OCIRepository** | Watches for new Flux Operator chart versions every 30 minutes |
| **cosign verify** | Only accepts charts cryptographically signed by the official ControlPlane GitHub Actions |
| **HelmRelease** | Automatically upgrades the operator when a new version is found |
| **dependsOn** | Waits until Helm CRDs exist before creating these resources |

!!! info "Self-upgrading infrastructure"
    The Flux Operator upgrades itself, which in turn upgrades the Flux controllers to the latest version. No manual Helm upgrades. No maintenance windows for Flux itself. It just stays current.

Commit and push:

```bash
git add -A
git commit -m "Add Flux Operator auto-upgrade ResourceSet"
git push origin main
```

Wait for Flux to pick it up, or trigger immediately:

```bash
flux reconcile kustomization flux-system --with-source
```

Verify:

```bash
flux get helmreleases
```

---

## 3. Commit Status Notifications

This closes the feedback loop. When you push a change to Git, Flux will update the commit status in GitHub — green checkmark for success, red cross for failure.

Create `clusters/training/flux-system/flux-notifications.yaml`:

```yaml
apiVersion: fluxcd.controlplane.io/v1
kind: ResourceSet
metadata:
  name: flux-notifications
  namespace: flux-system
spec:
  dependsOn:
    - apiVersion: apiextensions.k8s.io/v1
      kind: CustomResourceDefinition
      name: alerts.notification.toolkit.fluxcd.io
  resources:
    - apiVersion: notification.toolkit.fluxcd.io/v1beta3
      kind: Provider
      metadata:
        name: github-status
        namespace: flux-system
      spec:
        type: github
        address: https://github.com/swade1987/bs-fleet
        secretRef:
          name: github-auth
    - apiVersion: notification.toolkit.fluxcd.io/v1beta3
      kind: Alert
      metadata:
        name: github-status
        namespace: flux-system
      spec:
        providerRef:
          name: github-status
        eventSources:
          - kind: Kustomization
            name: flux-system
```

Commit and push:

```bash
git add -A
git commit -m "Add commit status notifications"
git push origin main
```

Trigger reconciliation:

```bash
flux reconcile kustomization flux-system --with-source
```

### The Result

Go to the GitHub repository. Next to the last commit, you'll see a **green checkmark** ✅ with the message "kustomization/flux-system reconciliation succeeded".

If a future commit breaks something, you'll see a **red cross** ❌ — you'll know immediately without checking the cluster.

!!! tip "Beyond GitHub"
    Flux also supports notifications to Slack, Discord, Microsoft Teams, and other providers. For production, you'd typically add Slack alerts so the team gets notified of deployment status in real-time.

---

## What We've Built

```
clusters/training/flux-system/
├── flux-instance.yaml        ← Flux controllers config (self-managed from Git)
├── flux-runtime-info.yaml    ← Cluster identity
├── flux-operator.yaml        ← Auto-upgrade ResourceSet (cosign verified)
└── flux-notifications.yaml   ← GitHub commit status alerts
```

Everything in this directory is managed by Flux. Change any file, push to Git, and Flux applies it automatically. The commit gets a green checkmark when reconciliation succeeds.

!!! success "From now on, we manage this cluster solely through Git"
    No more `kubectl apply`. No more Helm upgrades. No more SSHing into nodes to make changes. **Git is the single source of truth.**

Next: [Deploy your first app via Git →](first-deployment.md)
