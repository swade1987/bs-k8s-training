# Terminology Reference

A quick reference for all the terms used in this training.

---

## Kubernetes

| Term | What it is |
|------|-----------|
| **Control Plane** | The brain of a cluster — API server, scheduler, controller manager, etcd |
| **Worker Node** | A node that runs application workloads |
| **Pod** | The smallest deployable unit — one or more containers |
| **Deployment** | Manages a set of identical pods with rolling updates |
| **DaemonSet** | Ensures one pod runs on every node |
| **Namespace** | Logical division within a cluster |
| **Service** | Exposes pods to the network |
| **ConfigMap** | Stores non-sensitive configuration data as key-value pairs |
| **Secret** | Stores sensitive data (passwords, tokens, keys) |
| **PersistentVolume** | A piece of storage provisioned in the cluster |

## RKE2 & Calico

| Term | What it is |
|------|-----------|
| **RKE2** | Rancher Kubernetes Engine 2 — CIS-hardened Kubernetes distribution |
| **Calico** | Our CNI plugin — handles pod networking and network policy |
| **CNI** | Container Network Interface — the standard for Kubernetes networking plugins |
| **MTU** | Maximum Transmission Unit — we use 9000 (jumbo frames) for better throughput |
| **HelmChartConfig** | RKE2 resource to customise bundled Helm charts (e.g. Calico) |
| **containerd** | The container runtime used by RKE2 (instead of Docker) |

## Rancher

| Term | What it is |
|------|-----------|
| **Management Cluster (Hub)** | Lab 01 — runs Rancher, manages all other clusters |
| **Downstream Cluster (Spoke)** | Your lab — runs workloads, managed by Rancher |
| **cattle-cluster-agent** | Main agent in downstream clusters — WebSocket tunnel to Rancher |
| **cattle-node-agent** | DaemonSet on every node — fallback for cluster agent |
| **Authentication Proxy** | Rancher component that routes and authenticates kubectl requests |
| **Cluster Controller** | One per downstream cluster, runs on management cluster |
| **Project** | Groups namespaces with shared access control and resource quotas |
| **kubeconfig** | File that tells kubectl how to connect to a cluster |

## GitOps & Flux

| Term | What it is |
|------|-----------|
| **GitOps** | Using Git as the single source of truth for cluster state |
| **Flux** | CNCF GitOps tool — runs in-cluster, pulls from Git |
| **Source Controller** | Flux component that watches Git for changes |
| **Kustomize Controller** | Flux component that applies Kubernetes manifests |
| **Helm Controller** | Flux component that manages Helm chart releases |
| **Notification Controller** | Flux component that sends alerts and receives webhooks |
| **Reconciliation** | The process of making the cluster match what's declared in Git |
| **Drift** | When actual cluster state differs from what's in Git |
