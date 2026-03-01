# Fleet Design — Naming Conventions

Before we install Flux on anything, we need to answer a fundamental question: **how do you name and organise your clusters?**

Get this wrong now and you'll be refactoring your entire GitOps repository later. Get it right and every new cluster — whether it's an internal environment or a customer deployment — follows the same pattern.

---

## Your Reality

Business Solutions doesn't just run clusters for itself. You run clusters for **customers** — in their data centres, on their infrastructure, with their constraints.

That means your fleet repository needs to handle:

- **Internal clusters** — your own dev, staging, production environments
- **Customer clusters** — deployed on-prem in customer data centres
- **Different deployment models** — some customers get dedicated clusters, some might share

---

## Exercise: Design Your Naming Convention

!!! warning "This is a real architectural decision"
    There's no single right answer. But there are patterns that scale and patterns that don't. Work through this together.

### What Information Does a Cluster Name Need to Carry?

When someone looks at a cluster name in Rancher, in Git, or in a monitoring dashboard, they should immediately know:

| Question | Why It Matters |
|----------|---------------|
| **Who owns it?** | Is this ours or a customer's? |
| **What environment?** | Production? Staging? Dev? |
| **Where is it?** | Which data centre? Which region? On-prem or cloud? |
| **What's its purpose?** | Platform? Application? Monitoring? |

### A Starting Pattern

```
{owner}-{environment}-{location}-{purpose}
```

**Internal examples:**

```
bs-prod-ng-platform        ← BS production, Nova Gorica, platform cluster
bs-staging-ng-platform     ← BS staging, Nova Gorica
bs-dev-ng-platform         ← BS development, Nova Gorica
```

**Customer examples:**

```
merkur-prod-lj-erp         ← Merkur production, Ljubljana, ERP workloads
merkur-staging-lj-erp      ← Merkur staging, Ljubljana
acme-prod-mb-erp           ← Acme Corp production, Maribor
```

### Questions to Discuss

Work through these as a team:

1. **Owner segment** — Do you use the full customer name or a short code? What about customers with similar names?

2. **Environment segment** — How many environments per customer? Do all customers get staging, or only some?

3. **Location segment** — What level of granularity? Country? City? Data centre name? What about cloud regions?

4. **Purpose segment** — Do you need this? Or is one cluster per customer enough?

5. **Separator** — Hyphens, dots, underscores? Kubernetes has naming constraints (lowercase, no underscores in most contexts).

6. **Length** — Cluster names appear in kubectl output, Rancher UI, monitoring dashboards, log entries. Shorter is better — but not at the cost of clarity.

---

## The Fleet Repository Structure

Once you've agreed on naming, the repository structure follows directly. Every cluster gets its own directory under `clusters/`:

```
bs-fleet/
├── clusters/
│   │
│   │── bs-prod-ng-platform/
│   │   └── flux-system/
│   │       ├── flux-instance.yaml
│   │       ├── flux-runtime-info.yaml
│   │       ├── flux-operator.yaml
│   │       └── flux-notifications.yaml
│   │
│   │── bs-staging-ng-platform/
│   │   └── flux-system/
│   │       └── ...
│   │
│   │── bs-dev-ng-platform/
│   │   └── flux-system/
│   │       └── ...
│   │
│   │── merkur-prod-lj-erp/
│   │   └── flux-system/
│   │       └── ...
│   │
│   │── merkur-staging-lj-erp/
│   │   └── flux-system/
│   │       └── ...
│   │
│   │── acme-prod-mb-erp/
│   │   └── flux-system/
│   │       └── ...
│   │
│   └── ... (every cluster gets a directory)
│
├── infrastructure/
│   ├── controllers/       ← Shared infra (ingress, cert-manager, monitoring)
│   └── configs/           ← Shared configs (ClusterIssuers, storage classes)
│
└── apps/
    ├── base/              ← Base app manifests (DMS v2, ERP components)
    └── overlays/          ← Per-customer or per-environment overrides
```

### Why Flat?

Notice there are **no subdirectories** under `clusters/`. No `clusters/internal/` and `clusters/customers/`. Every cluster sits at the same level.

Why?

- **Flux's sync path is per-cluster.** Each FluxInstance points to its own directory. Nesting adds no value to Flux.
- **Flat is searchable.** `ls clusters/` shows every cluster. `ls clusters/ | grep merkur` shows all Merkur clusters.
- **Flat scales.** Whether you have 5 clusters or 500, the pattern is the same.
- **The naming convention carries the hierarchy.** You don't need `clusters/customers/merkur/prod/` when the name `merkur-prod-lj-erp` already tells you everything.

---

## Connecting to Flux

Each cluster's `flux-instance.yaml` points to its own directory:

```yaml
# In merkur-prod-lj-erp's FluxInstance
spec:
  sync:
    kind: GitRepository
    url: "https://github.com/swade1987/bs-fleet.git"
    ref: "refs/heads/main"
    path: "clusters/merkur-prod-lj-erp"
```

```yaml
# In bs-prod-ng-platform's FluxInstance
spec:
  sync:
    kind: GitRepository
    url: "https://github.com/swade1987/bs-fleet.git"
    ref: "refs/heads/main"
    path: "clusters/bs-prod-ng-platform"
```

Same repo, different paths. Each cluster only sees and applies its own configuration.

---

## The Runtime Info ConfigMap

The naming convention feeds directly into the cluster identity:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: flux-runtime-info
  namespace: flux-system
  labels:
    toolkit.fluxcd.io/runtime: "true"
data:
  OWNER: merkur
  ENVIRONMENT: production
  LOCATION: lj
  PURPOSE: erp
  CLUSTER_NAME: merkur-prod-lj-erp
  CLUSTER_DOMAIN: merkur-prod-lj-erp.k.bs.internal
```

This data is available to any application running in the cluster. Your DMS deployment can read it to know which customer it's serving.

---

## For Today's Training

During this training, your cluster names follow the lab convention:

```
clusters/
├── lab-02-aleksander/
├── lab-03-ales/
├── lab-04-damir/
├── lab-05-erikp/
├── lab-06-eriks/
├── lab-07-luka/
├── lab-08-nejc/
└── lab-09-sani/
```

This is a **training convention**, not a production one. The exercise above is about designing what the real convention will look like when you go to production.

!!! question "Take-Home Decision"
    Before this engagement ends, the team needs to agree on a naming convention and document it. This becomes the standard that every future cluster follows. The convention you choose today will appear in:

    - Rancher cluster names
    - Git repository paths
    - DNS entries
    - Monitoring dashboards
    - Runbooks and documentation
    - Customer contracts

    It needs to be right.
