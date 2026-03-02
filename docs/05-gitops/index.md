# GitOps with Flux — Day 2

Yesterday you built the infrastructure. Today you design **how to manage it at scale** — and then make it real with Flux.

---

## What You'll Do Today

- [ ] Design a cluster naming convention for BS internal and customer clusters
- [ ] Install the Flux Operator via Helm
- [ ] Bootstrap Flux from the fleet Git repository
- [ ] Configure auto-upgrades and commit status notifications
- [ ] First GitOps deployments using your repo structure (Steve-led)

---

## Sections

| Section | What You'll Learn |
|---------|------------------|
| **[Fleet Design](fleet-design.md)** | Naming conventions for internal + customer clusters |
| **[Install Flux Operator](install-operator.md)** | Helm install of the Flux Operator |
| **[Create FluxInstance](create-instance.md)** | Bootstrap Flux with the four-repo model |
| **[Cluster Configuration](cluster-config.md)** | Runtime info, auto-upgrades, commit notifications |

!!! info "Repo structure, deployments, and secrets"
    The afternoon session covers your four-repo model, first GitOps deployments, and SOPS+age secrets — delivered live and tailored to your setup.

---

## Prerequisites

Before starting, confirm:

- [x] Your cluster is **Active** in Rancher
- [x] `kubectl get nodes` works from your local machine
- [x] You have `helm` installed locally

```bash
# Quick check
kubectl get nodes
helm version
```
