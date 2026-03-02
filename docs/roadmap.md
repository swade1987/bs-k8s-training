# Training Roadmap

Five days. Building your Kubernetes platform together.

---

## Day 1 — Kubernetes Fundamentals & Management Cluster :material-check-circle:{ .green }

**Status:** Complete

Building shared understanding before touching infrastructure. Kubernetes architecture, core resources, networking model, and how it all fits together - then applying it to the management cluster build.

- [x] Kubernetes architecture - control plane, workers, etcd, API server
- [x] Core resources - Pods, Deployments, Services etc
- [x] Networking model - CNI, Services, DNS, ingress
- [x] Container runtime and container patterns
- [x] Rancher overview
- [x] Management cluster build begins

[:material-arrow-right: Day 1 Content](01-concepts/kubernetes.md)

---

## Day 2 — Downstream Clusters + GitOps with Flux :material-lock-outline:

**Status:** Tomorrow

Complete the cluster builds, then move into GitOps. Git becomes the single source of truth.

- [ ] Complete management cluster (Rancher operational)
- [ ] Downstream cluster provisioning via Rancher (hands-on)
- [ ] Workstation setup and kubectl access
- [ ] Design a cluster naming convention for your fleet
- [ ] Install Flux Operator and bootstrap from the fleet repo
- [ ] The four-repo model: fleet, platform, DMS, secrets
- [ ] First GitOps deployments (platform + DMS)
- [ ] Centralised secrets with SOPS + age encryption

**By end of day:** Clusters operational and managed through Git. Four repos, clear ownership, encrypted secrets.

---

## Day 3 :material-lock-outline:

**Status:** Content added based on progress

---

## Day 4 :material-lock-outline:

**Status:** Content added based on progress

---

## Day 5 :material-lock-outline:

**Status:** Content added based on progress

---

!!! tip "New content drops daily"
Each morning, the next day's material will appear on this site. Bookmark it and check back.
