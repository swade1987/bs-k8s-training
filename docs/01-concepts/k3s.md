# Why K3s?

There are many ways to install Kubernetes — kubeadm, RKE2, managed services like EKS, AKS, or GKE. So why K3s?

---

## What Is K3s?

**K3s** is a lightweight, certified Kubernetes distribution built by SUSE (the same company that makes Rancher). It's packaged as a single binary under 70MB, designed for production workloads where resources are constrained.

---

## What Makes It Different

**Lightweight**
:   Single binary, ~70MB. Installs in seconds, not minutes. Runs on everything from a Raspberry Pi to a full server.

**Resource Efficient**
:   Minimum 2 CPU / 2GB RAM for a server node. 1 CPU / 512MB for a worker. That matters when you're deploying clusters into customer data centres where the compute cost needs to match your current Windows deployments.

**No Docker Dependency**
:   Uses containerd directly as the container runtime — lighter and smaller attack surface.

**Simple to Install**
:   One curl command. One environment variable for the token. That's it.

**Batteries Included**
:   Bundles Traefik ingress, CoreDNS, local-path storage, and a service load balancer out of the box. We disable some of these when using our own alternatives (e.g. Calico for networking).

**Rancher Integration**
:   Same SUSE ecosystem — Rancher can provision K3s clusters, upgrade them, and manage their lifecycle from the UI.

**Production Certified**
:   K3s is a fully CNCF-certified Kubernetes distribution. It passes the same conformance tests as any other distribution. Lightweight doesn't mean limited.

---

## K3s vs RKE2

| | K3s | RKE2 |
|---|-----|------|
| **Binary size** | ~70MB | ~300MB+ |
| **Min server RAM** | 2GB | 4GB |
| **Min server CPU** | 2 cores | 2 cores |
| **CIS hardened** | Optional | By default |
| **Best for** | Edge, on-prem, resource-constrained | High-security, regulated environments |
| **Install time** | Seconds | Minutes |

For Business Solutions, where customer deployments need to match the compute footprint of existing Windows infrastructure, K3s is the right choice. The resource savings go directly to the bottom line — no infrastructure up-charge to move customers to Kubernetes.

---

## Production Sizing Recommendations

### Server Nodes (Control Plane + etcd)

| Cluster Size | CPU | RAM | Disk |
|-------------|-----|-----|------|
| Up to 350 agents | 2 cores | 4 GB | 50 GB SSD |
| Up to 900 agents | 4 cores | 8 GB | 100 GB SSD |
| Up to 1800 agents | 8 cores | 16 GB | 200 GB SSD |

!!! important "Always use SSDs for server nodes"
    etcd is write-intensive. Spinning disks or SD cards cannot handle the IO load and will cause cluster instability.

### Agent Nodes (Workers)

| Workload Type | CPU | RAM | Disk |
|--------------|-----|-----|------|
| Light (DMS, small ERP) | 2 cores | 4 GB | 50 GB |
| Medium (multiple services) | 4 cores | 8 GB | 100 GB |
| Heavy (databases, large ERP) | 8 cores | 16 GB | 200 GB SSD |

Worker sizing depends entirely on what you're running. The figures above are for the K3s agent overhead plus typical workloads.

### HA Recommendations

For production, always run **3 server nodes** for high availability. With 3 servers, etcd can tolerate the loss of 1 node and still maintain quorum.

With a 3-server HA setup, agent capacity scales roughly **50% higher** than the table above.

---

!!! info "During this training"
    Rancher installs K3s for you on downstream clusters when you run the registration command. You'll see this in action during the hands-on sections.
