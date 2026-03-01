# Create a FluxInstance

The FluxInstance tells the operator **which Flux controllers to deploy** and **where to sync from.** After this step, the cluster is bootstrapped and managed through Git.

---

## The Four-Repo Model

Unlike the single-repo approach in the Flux docs, we split configuration by concern. This gives clear ownership and avoids a single monolithic repo that confuses everyone.

| Repository                | Owner | Purpose |
|---------------------------|-------|---------|
| **k8s-fleet**             | Steve / Platform Lead | Flux bootstrap — FluxInstance, operator config, notifications |
| **k8s-resources-platform** | Platform Engineering | Cluster infrastructure — ingress, monitoring, cert-manager, policies |
| **k8s-resources-dms**     | DMS Team | Application deployment — DMS v2 config across clusters |
| **k8s-secrets**           | Platform Engineering | Centralised secrets — encrypted with SOPS + age |

```
┌─────────────────────────────────────────────────────────┐
│  Your Cluster                                           │
│                                                         │
│  Flux watches FOUR repos:                               │
│                                                         │
│  k8s-fleet ─────────────→ Bootstrap + Flux self-config  │
│  k8s-resources-platform ─→ Platform infra (ingress, etc)│
│  k8s-resources-dms ─────→ DMS app deployments           │
│  k8s-secrets ───────────→ Encrypted secrets (SOPS+age)  │
└─────────────────────────────────────────────────────────┘
```

**Why split?**

- **Ownership is clear.** Platform team doesn't need access to DMS config. DMS team doesn't touch ingress controllers.
- **Blast radius is smaller.** A bad commit to the DMS repo doesn't break platform infrastructure.
- **Permissions are simple.** Each repo has its own access controls. The secrets repo is locked down tight.
- **Onboarding is easier.** New developer? "Your repo is `k8s-resources-dms-bs`. That's all you need to know."

---

## Step 1: Clone the Fleet Repository

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

Commit and push:

```bash
git add -A
git commit -m "Add FluxInstance for training cluster"
git push origin main
```

---

## Step 3: Create the Git Authentication Secret

```bash
export GITHUB_TOKEN=<your-github-pat>

flux create secret git github-auth \
  --url=https://github.com/swade1987/bs-fleet.git \
  --username=flux \
  --password=$GITHUB_TOKEN
```

!!! warning "Steve will provide PAT details during the training"

---

## Step 4: Apply the FluxInstance (One Time Only)

```bash
kubectl apply -f clusters/training/flux-system/flux-instance.yaml
```

This is the **only manual kubectl apply.** From now on, Flux manages itself from Git.

---

## Step 5: Watch It Bootstrap

```bash
kubectl -n flux-system get pods -w
```

Wait for all controllers to show `Running`:

```
flux-operator-xxxxxxxxxx-xxxxx             1/1     Running
source-controller-xxxxxxxxxx-xxxxx         1/1     Running
kustomize-controller-xxxxxxxxxx-xxxxx      1/1     Running
helm-controller-xxxxxxxxxx-xxxxx           1/1     Running
notification-controller-xxxxxxxxxx-xxxxx   1/1     Running
```

### Verify

```bash
kubectl get fluxinstance -n flux-system
kubectl get gitrepository -n flux-system
kubectl get kustomization -n flux-system
```

All should show `Ready: True`.

---

## The Bootstrap Loop

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
    The FluxInstance lives in Git. Flux watches that Git repo. Change the FluxInstance in Git → Flux applies the change to itself. **No more kubectl. Just Git.**

Next: [Cluster configuration →](cluster-config.md)
