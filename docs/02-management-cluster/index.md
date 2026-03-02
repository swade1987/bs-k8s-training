# Management Cluster (Lab 01)

!!! info "This section is a Steve-led demo"
    The management cluster has already been built. This section documents the process for reference. Your hands-on work starts in [Section 3: Downstream Clusters](../03-downstream-clusters/index.md).

---

## What We're Building

A **7-node K3s high-availability cluster** running Rancher as the management plane for all labs.

| Node | IP | Role |
|------|-----|------|
| k01m1 | 10.188.1.11 | Control Plane + etcd |
| k01m2 | 10.188.1.12 | Control Plane + etcd |
| k01m3 | 10.188.1.13 | Control Plane + etcd |
| k01w1 | 10.188.1.21 | Worker |
| k01w2 | 10.188.1.22 | Worker |
| k01w3 | 10.188.1.23 | Worker |
| k01w4 | 10.188.1.31 | Monitoring (dedicated) |

**Rancher URL:** [https://steve.k.ma-no.si](https://steve.k.ma-no.si)

---

## Build Phases

| Phase | What | Time |
|-------|------|------|
| [Phase 0](phase0-token.md) | Generate shared K3s token | 1 min |
| [Phase 1](phase1-prep.md) | Prepare all 7 nodes | 10 min |
| [Phase 2](phase2-first-master.md) | Install K3s on first server (k01m1) | 3 min |
| [Phase 3](phase3-join-masters.md) | Join k01m2 and k01m3 | 10 min |
| [Phase 4](phase4-join-workers.md) | Join all workers | 10 min |
| [Phase 5](phase5-helm.md) | Install Helm | 1 min |
| [Phase 6](phase6-cert-manager.md) | Install cert-manager | 3 min |
| [Phase 7](phase7-rancher.md) | Install Rancher | 5 min |
| **Total** | | **~45 min** |

---

## Quick Reference

```
Public:   https://steve.k.ma-no.si (46.54.226.201:443)
Internal: https://10.188.1.11

Bootstrap password: KubeTraining2025!

Masters: 10.188.1.11, .12, .13
Workers: 10.188.1.21, .22, .23
Monitor: 10.188.1.31
```
