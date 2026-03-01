# Understanding Rancher

Kubernetes is brilliant at running containers, but managing Kubernetes itself is hard. One cluster is manageable. Five? Ten? Each needs its own authentication, monitoring, upgrades. You end up with a sprawl of kubeconfig files, different versions, different configurations.

**Rancher solves this by giving you a single pane of glass to manage all of your Kubernetes clusters.** One login, one dashboard, one place to see everything.

Think of it this way: Kubernetes manages your containers. **Rancher manages your Kubernetes.**

---

## The Hub and Spoke Model

Rancher uses a **hub and spoke** architecture.

The **hub** is the management cluster (Lab 01). It runs the Rancher server and nothing else — no application workloads.

The **spokes** are the downstream clusters (Labs 02–09). These are where your applications run.

```
                      ┌──────────────────────┐
                      │   RANCHER (Hub)      │
                      │   Lab 01 - Steve     │
                      │   steve.k.ma-no.si   │
                      └──────────┬───────────┘
                                 │
        ┌────────┬───────┬───────┼───────┬────────┬────────┬────────┐
        │        │       │       │       │        │        │        │
     Lab 02   Lab 03  Lab 04  Lab 05  Lab 06   Lab 07   Lab 08   Lab 09
   Aleksandr   Aleš   Damir   ErikP   ErikS    Luka     Nejc     Sani
```

They're separated on purpose — if Rancher goes down, your applications keep running. If an application cluster has problems, Rancher stays up and can help you fix it.

---

## Management Cluster Components

Four main components run on the management cluster:

### Rancher API Server

The core of Rancher. Built on top of the standard Kubernetes API server with extra functionality. Handles user management, authentication, access control, and cluster management logic. All data is stored as Custom Resource Definitions (CRDs) in etcd.

### Authentication Proxy

How your `kubectl` commands reach downstream clusters. The proxy checks who you are, verifies permissions, and forwards requests using Kubernetes impersonation headers. One Rancher login manages multiple clusters.

### Cluster Controllers

One controller per downstream cluster. Once all your clusters are connected, there will be **eight** cluster controllers running on the management cluster. Each watches its downstream cluster for changes and handles provisioning.

### etcd

Stores all configuration — cluster definitions, users, roles. Three master nodes means if one goes down, etcd still has a quorum of two and Rancher keeps working.

---

## Downstream Cluster Agents

When your cluster connects to Rancher, two agents are deployed into it:

### Cluster Agent (cattle-cluster-agent)

The main communication channel. Runs as a **Deployment** (one pod, usually on a control plane node). Opens a **WebSocket tunnel** back to Rancher.

!!! important "The connection is outbound"
    The cluster agent initiates the connection **from** your cluster **to** Rancher. Rancher doesn't reach into your cluster. Your cluster only needs to reach Rancher on **port 443**.

### Node Agent (cattle-node-agent)

Runs as a **DaemonSet** — one pod on **every** node. Handles node-level operations (K8s upgrades, etcd snapshots). Acts as a **fallback** if the cluster agent goes down.

```
Your Downstream Cluster
┌───────────────────────────────────────────────────────┐
│                                                       │
│  ┌──────────────────────┐                             │
│  │ cattle-cluster-agent │ ─── WebSocket tunnel ────── │ ──→ Rancher
│  │ (1 pod, Deployment)  │                             │    (port 443)
│  └──────────────────────┘                             │
│                                                       │
│  ┌─────────────────┐ ┌─────────────────┐ ┌────────┐  │
│  │cattle-node-agent│ │cattle-node-agent│ │  ...   │  │
│  │ (every node)    │ │ (every node)    │ │        │  │
│  └─────────────────┘ └─────────────────┘ └────────┘  │
│       ↑ fallback           ↑ fallback                 │
└───────────────────────────────────────────────────────┘
```

---

## How kubectl Works Through Rancher

When you run `kubectl get pods` using the Rancher-downloaded kubeconfig:

1. Your machine sends the request to **Rancher** (steve.k.ma-no.si:443)
2. The **Authentication Proxy** checks your token and permissions
3. Rancher sets **impersonation headers** for your downstream service account
4. The request forwards through the **WebSocket tunnel** to the downstream API server
5. The response returns the same path

```
You (kubectl get pods)
    │
    ▼
Rancher (steve.k.ma-no.si:443)
    ├── Authenticate your token
    ├── Check permissions
    ├── Set impersonation headers
    │
    ▼
WebSocket tunnel → Downstream API server
    │
    ▼
Response returns the same path
```

This is why the Rancher kubeconfig works from **anywhere** — your machine only needs to reach Rancher on port 443.

---

## What Happens If Rancher Goes Down?

**Your downstream clusters keep running.** Applications don't stop. Pods don't restart. The clusters are fully independent.

What you lose is the management plane — no Rancher UI, no proxied kubeconfig.

!!! tip "Emergency Access"
    If Rancher is down, SSH into a master node and use the local kubeconfig:
    ```bash
    export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
    kubectl get nodes
    ```

---

## Projects, Namespaces, and RBAC

### Projects

A Rancher concept on top of Kubernetes namespaces. A **Project** groups namespaces with shared access control and resource quotas.

New clusters get two projects automatically:

- **System** — infrastructure namespaces (`kube-system`, `cattle-system`)
- **Default** — where you deploy applications

### RBAC Layers

| Level | Scope | Example |
|-------|-------|---------|
| **Global** | All clusters | Admin can manage everything |
| **Cluster** | One cluster | Cluster Owner has full control |
| **Project** | Namespaces in a project | Project Owner can deploy workloads |

!!! example "Your Setup Today"
    Each of you has a Rancher account with **Cluster Owner** access to your own cluster. Full control over yours, no visibility into anyone else's.

---

## What to Expect in the Rancher UI

When you log in, you'll see:

- **Cluster Management** — all clusters with their status (Active / Provisioning / Error)
- **Cluster Explorer** — visual kubectl: workloads, services, storage, config, nodes
- **kubectl Shell** — browser-based terminal, already authenticated
- **Apps & Charts** — install Helm charts from the UI
- **Continuous Delivery** — Rancher's built-in GitOps engine (Fleet)

!!! note "Fleet vs Flux"
    Rancher ships with **Fleet**, its own GitOps engine. We're using **Flux** instead — it's the more widely adopted CNCF tool and the skills transfer to any Kubernetes environment, not just Rancher.
