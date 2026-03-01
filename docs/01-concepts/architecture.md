# How It All Fits Together

Here's the complete picture of what we're building:

---

## The Four Layers

```
┌─────────────────────────────────────────────────────────┐
│                        Git Repository                    │
│           (the single source of truth)                   │
└────────────────────────────┬────────────────────────────┘
                             │ pull
                             ▼
┌─────────────────────────────────────────────────────────┐
│ Layer 4: FLUX (in each downstream cluster)               │
│          Watches Git → applies config → self-heals       │
├─────────────────────────────────────────────────────────┤
│ Layer 3: RANCHER (management cluster, Lab 01)            │
│          Single UI → auth → multi-cluster management     │
├─────────────────────────────────────────────────────────┤
│ Layer 2: RKE2 + CALICO (on every node)                   │
│          Kubernetes runtime → pod networking              │
├─────────────────────────────────────────────────────────┤
│ Layer 1: HYPER-V (VMs running Ubuntu 24.04)              │
│          Compute → storage → base networking             │
└─────────────────────────────────────────────────────────┘
```

---

## Defence in Depth

Each layer is independent:

| If this fails... | What happens |
|-------------------|-------------|
| Rancher goes down | Flux keeps reconciling from Git. Clusters keep running. |
| Flux has a problem | Rancher still manages the clusters. Existing workloads unaffected. |
| A VM has an issue | Kubernetes reschedules pods to healthy nodes. |
| Git is unreachable | Flux retries. Cluster stays in its last known-good state. |

No single failure takes down the whole stack.

---

## Our Training Setup

| Component | Details |
|-----------|---------|
| **VMs** | 63 total (9 labs × 7 nodes), Ubuntu 24.04.4 on Hyper-V |
| **Kubernetes** | RKE2 with Calico CNI (MTU 9000) |
| **Management** | Rancher on Lab 01 managing all 9 clusters |
| **GitOps** | Flux on each downstream cluster |
| **Networking** | Shared 10.188.0.0/16 network across all labs |
