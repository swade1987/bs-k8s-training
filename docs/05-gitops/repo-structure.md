# Repository Structure

You've seen Flux work with a simple example. But how do you organise a Git repository for **real production use?**

---

## The Training Structure (Simple)

What we've been using:

```
bs-fleet/
├── clusters/
│   └── training/
│       ├── namespaces/
│       └── apps/
│           └── podinfo/
```

This works for learning. One cluster, one path, everything flat. But production needs more.

---

## A Production Structure (What You'll Need)

```
bs-fleet/
├── clusters/
│   ├── production/          ← Production cluster config
│   │   ├── flux-system/     ← Flux instance and patches
│   │   ├── infrastructure/  ← HelmReleases for infra tools
│   │   └── apps/            ← Application deployments
│   ├── staging/             ← Staging cluster config
│   │   ├── flux-system/
│   │   ├── infrastructure/
│   │   └── apps/
│   └── development/         ← Dev cluster config
│       ├── flux-system/
│       ├── infrastructure/
│       └── apps/
├── infrastructure/
│   ├── controllers/         ← Shared infra (ingress, cert-manager, monitoring)
│   └── configs/             ← Shared configs (ClusterIssuers, storage classes)
└── apps/
    ├── base/                ← Base app manifests
    ├── production/          ← Production overlays (replicas, resources, env vars)
    ├── staging/             ← Staging overlays
    └── development/         ← Dev overlays
```

---

## Key Concepts

### Separation of Concerns

| Directory | Who Owns It | What's In It |
|-----------|-------------|-------------|
| `clusters/` | Platform team | What gets deployed where |
| `infrastructure/` | Platform team | Shared tooling (ingress, monitoring, certs) |
| `apps/base/` | App developers | Application manifests |
| `apps/{env}/` | App developers | Environment-specific overrides |

### Kustomize Overlays

The `base/` directory contains the common application definition. Each environment directory contains **overlays** that modify the base for that environment:

- **Production:** 3 replicas, 512Mi memory, real database connection
- **Staging:** 2 replicas, 256Mi memory, staging database
- **Development:** 1 replica, 128Mi memory, local database

Same app, different configurations — all in Git.

### Dependency Ordering

Flux supports dependencies between Kustomizations. Infrastructure deploys before apps:

```
infrastructure/controllers  →  infrastructure/configs  →  apps
       (first)                     (second)              (third)
```

This ensures the ingress controller exists before apps try to create Ingress resources.

---

## Questions This Raises

!!! question "Things to think about"
    - How do you handle **secrets** in Git? (You can't commit passwords in plain text)
    - How do you **promote** a change from staging to production?
    - What's the **branching strategy** — one branch per environment, or directories on main?
    - How do you handle **Helm values** that differ per environment?
    - What happens when **two teams** need to deploy to the same cluster?
    - How do you implement **approval gates** before production deploys?

These are architectural decisions that need careful design for your specific environment. We'll explore some of these in the coming days.

---

## Further Reading

- [Flux Kustomize Helm Example](https://github.com/fluxcd/flux2-kustomize-helm-example) — the reference repository structure from the Flux project
- [Flux Operator Cluster Sync Guide](https://fluxoperator.dev/docs/instance/sync/) — configuration options for Git, OCI, and S3 sync
- [Flux Monitoring and Reporting](https://fluxoperator.dev/docs/guides/monitoring/) — deep insights into your GitOps pipelines
