# Create a FluxInstance

The FluxInstance tells the operator **which Flux controllers to deploy** and **where to sync from.** After this step, the cluster is fully managed through Git.

---

## Step 1: Set Up the Fleet Repository

Clone the fleet repository:

```bash
git clone https://github.com/swade1987/bs-fleet.git
cd bs-fleet
```

Create the directory structure for your cluster:

```bash
mkdir -p clusters/training/flux-system
```

---

## Step 2: Create the FluxInstance Manifest

Create `clusters/training/flux-system/flux-instance.yaml`:

```yaml
apiVersion: fluxcd.controlplane.io/v1
kind: FluxInstance
metadata:
  name: flux
  namespace: flux-system
spec:
  distribution:
    version: "2.x"
    registry: "ghcr.io/fluxcd"
    artifact: "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests:latest"
  components:
    - source-controller
    - kustomize-controller
    - helm-controller
    - notification-controller
  cluster:
    type: kubernetes
    multitenant: true
    tenantDefaultServiceAccount: flux
    networkPolicy: true
    domain: "cluster.local"
  sync:
    kind: GitRepository
    url: "https://github.com/swade1987/bs-fleet.git"
    ref: "refs/heads/main"
    path: "clusters/training"
    pullSecret: "github-auth"
  kustomize:
    patches:
      - target:
          kind: Deployment
          name: "(kustomize-controller|helm-controller)"
        patch: |
          - op: add
            path: /spec/template/spec/containers/0/args/-
            value: --concurrent=10
          - op: add
            path: /spec/template/spec/containers/0/args/-
            value: --requeue-dependency=5s
```

---

## Understanding the Config

| Field | What It Does |
|-------|-------------|
| `distribution.version: "2.x"` | Auto-selects latest Flux 2.x stable |
| `components` | Which Flux controllers to install |
| `cluster.multitenant: true` | Enables tenant isolation with dedicated service accounts |
| `cluster.networkPolicy: true` | Creates network policies to secure controller communication |
| `sync.kind: GitRepository` | Tells Flux to watch a Git repository |
| `sync.url` | The fleet repository to sync from |
| `sync.path: "clusters/training"` | Only sync manifests from this directory |
| `sync.pullSecret: "github-auth"` | Kubernetes secret with Git credentials |
| `kustomize.patches` | Performance tuning — 10 concurrent reconciliations, faster dependency requeue |

!!! info "Why multitenant?"
    Even for a single-team setup, multitenant mode enforces better security defaults. Each namespace gets its own service account for Flux operations, preventing cross-namespace access.

---

## Step 3: Commit and Push

```bash
git add -A
git commit -m "Add FluxInstance for training cluster"
git push origin main
```

The manifest is now in Git. But Flux isn't watching yet — we need to apply it once manually to bootstrap the loop.

---

## Step 4: Create the Git Authentication Secret

Set your GitHub PAT as an environment variable:

```bash
export GITHUB_TOKEN=<your-github-pat>
```

Create the secret:

```bash
flux create secret git github-auth \
  --url=https://github.com/swade1987/bs-fleet.git \
  --username=flux \
  --password=$GITHUB_TOKEN
```

!!! warning "You need a GitHub PAT"
    Steve will provide access details during the training. The PAT needs `repo` scope to read the fleet repository.

---

## Step 5: Apply the FluxInstance (One Time Only)

```bash
kubectl apply -f clusters/training/flux-system/flux-instance.yaml
```

This is the **only time you run kubectl apply for Flux.** From now on, Flux manages itself from Git.

---

## Step 6: Watch It Come Alive

```bash
kubectl -n flux-system get pods -w
```

You'll see the four Flux controllers start up one by one:

```
NAME                                       READY   STATUS    RESTARTS   AGE
flux-operator-xxxxxxxxxx-xxxxx             1/1     Running   0          5m
source-controller-xxxxxxxxxx-xxxxx         1/1     Running   0          30s
kustomize-controller-xxxxxxxxxx-xxxxx      1/1     Running   0          30s
helm-controller-xxxxxxxxxx-xxxxx           1/1     Running   0          30s
notification-controller-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
```

---

## Step 7: Verify

### Check the FluxInstance

```bash
kubectl get fluxinstance -n flux-system
```

```
NAME   READY   STATUS                      AGE
flux   True    Reconciliation finished     60s
```

### Check Git sync

```bash
kubectl get gitrepository -n flux-system
kubectl get kustomization -n flux-system
```

Both should show `Ready: True`.

### Inspect the FluxReport

```bash
kubectl -n flux-system get fluxreport flux -o yaml
```

This shows controller versions, reconciler stats, and sync status.

---

## The Bootstrap Loop

Here's what just happened — and why it's powerful:

```
1. You applied FluxInstance manually (one time)
       │
       ▼
2. Operator deployed Flux controllers
       │
       ▼
3. Source Controller started watching bs-fleet.git
       │
       ▼
4. Found flux-instance.yaml in clusters/training/flux-system/
       │
       ▼
5. Flux now manages its OWN configuration from Git
```

!!! success "The loop is closed"
    The FluxInstance manifest lives in Git. Flux is watching that same Git repo. If you change the FluxInstance in Git (add a component, change a version, adjust a patch), Flux applies the change to itself. **No more kubectl. No more Helm upgrades. Just Git.**

---

## What's Running Now

```
Your Cluster
┌─────────────────────────────────────────────────────────┐
│  flux-system namespace                                  │
│                                                         │
│  ┌────────────────────┐                                 │
│  │  flux-operator     │ ← Manages the controllers       │
│  └────────────────────┘                                 │
│                                                         │
│  ┌────────────────────┐  ┌──────────────────────┐       │
│  │ source-controller  │  │ kustomize-controller │       │
│  │ (watches Git)      │  │ (applies manifests)  │       │
│  └────────┬───────────┘  └──────────┬───────────┘       │
│           │                         │                    │
│           ▼                         ▼                    │
│  ┌────────────────────┐  ┌──────────────────────┐       │
│  │ helm-controller    │  │notification-controller│      │
│  │ (manages charts)   │  │ (sends alerts)       │       │
│  └────────────────────┘  └──────────────────────┘       │
│                                                         │
│  GitRepository: bs-fleet.git ──→ clusters/training      │
│  Secret: github-auth (PAT)                              │
└─────────────────────────────────────────────────────────┘
```

Next: [Add cluster info and auto-upgrades →](cluster-config.md)
