# Training Roadmap

Five days. From VMs to production-ready GitOps platform.

---

## Day 1 — Infrastructure & Cluster Build :material-check-circle:{ .green }

**Status:** Ready

Build the foundation. Management cluster, downstream clusters, Rancher multi-cluster management.

- [x] Kubernetes & Rancher architecture concepts
- [x] RKE2 management cluster build (Steve-led demo)
- [x] Downstream cluster provisioning via Rancher (hands-on)
- [x] Calico CNI with MTU 9000
- [x] Workstation setup and kubectl access

**By end of day:** 9 clusters, 63 nodes, all managed from a single Rancher dashboard.

[:material-arrow-right: Start Day 1](01-concepts/kubernetes.md)

---

## Day 2 — GitOps with Flux :material-lock-outline:

**Status:** Unlocks tomorrow

Git becomes the single source of truth. Every deployment, every config change — driven by commits, not commands.

- Flux installation and bootstrapping
- Repository structure for GitOps
- First application deployed via Git
- Reconciliation and self-healing in action
- Kustomize overlays for environment separation

**By end of day:** Your cluster auto-deploys from Git. Push a commit, watch it appear.

---

## Day 3 — Observability & Monitoring :material-lock-outline:

**Status:** Coming soon

You can't manage what you can't see. Build the monitoring stack that gives you visibility across the platform.

- Prometheus and Grafana deployment
- Cluster health dashboards
- Alerting rules and thresholds
- Log aggregation
- Monitoring node configuration

**By end of day:** Dashboards showing real-time cluster and application health.

---

## Day 4 — Security & Access Control :material-lock-outline:

**Status:** Coming soon

Lock it down. RBAC, network policies, secrets management — the controls that make this production-grade.

- RBAC design and implementation
- Network policies for namespace isolation
- Secrets management patterns
- Pod security standards

**By end of day:** Properly secured cluster with least-privilege access and network segmentation.

---

## Day 5 — Production Readiness :material-lock-outline:

**Status:** Coming soon

The bridge from training environment to real-world platform. Everything you need to take this into production.

- Production deployment checklist
- Backup and disaster recovery
- Upgrade strategies
- Capacity planning

**By end of day:** A clear path from where you are to where you need to be.

---

!!! tip "New content drops daily"
    Each morning, the next day's material will appear on this site. Bookmark it and check back.
