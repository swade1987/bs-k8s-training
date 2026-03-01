# Kubernetes Refresher

Before we talk about Rancher, let's make sure we're all on the same page with Kubernetes concepts.

---

## Cluster Architecture

A Kubernetes cluster is a group of machines working together to run your containerised applications. Those machines fall into two categories.

### Control Plane Nodes

Sometimes called **masters** — these run the brains of the cluster:

**API Server**
:   The front door. Every `kubectl` command talks to the API server.

**Scheduler**
:   Decides which node should run a new pod.

**Controller Manager**
:   Watches the state of the cluster and makes corrections — if a pod dies, the controller manager notices and creates a new one.

**etcd**
:   The database. Stores the entire state of the cluster. If etcd is lost, the cluster is lost.

### Worker Nodes

These run your actual workloads:

**kubelet**
:   Receives instructions from the control plane and makes sure containers are running.

**kube-proxy**
:   Handles networking so pods can talk to each other and to the outside world.

---

## Key Concepts

**Pod**
:   The smallest deployable unit — one or more containers that share storage and networking.

**Deployment**
:   Manages a set of identical pods and handles rolling updates.

**DaemonSet**
:   Ensures one pod runs on **every** node — useful for monitoring agents or network plugins.

**Namespace**
:   A way to divide a cluster into logical sections.

**Service**
:   Exposes pods to the network so other things can find them.

---

!!! tip "Everything we do today builds on these concepts"
    If any of these terms are unfamiliar, ask now — it's much easier to clarify upfront than to get lost later.
