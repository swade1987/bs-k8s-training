# Why RKE2?

There are many ways to install Kubernetes — kubeadm, K3s, managed services like EKS, AKS, or GKE. So why RKE2?

---

## What Is RKE2?

**RKE2** stands for Rancher Kubernetes Engine 2. It's built by SUSE (the same company that makes Rancher) and designed for production environments where security matters.

---

## What Makes It Different

**CIS-Hardened by Default**
:   CIS (Center for Internet Security) publishes benchmarks for secure Kubernetes. Most installers require you to apply these manually. RKE2 ships with them turned on from the start.

**No Docker Dependency**
:   RKE2 uses containerd directly as the container runtime — lighter and smaller attack surface than Docker.

**Simple to Install**
:   One curl command downloads the installer. One config file configures the node. One systemctl command starts it.

**Batteries Included**
:   RKE2 bundles the Nginx ingress controller, CoreDNS, and your chosen CNI plugin. No separate installation needed.

**Rancher Integration**
:   Made by the same team — Rancher can provision RKE2 clusters, upgrade them, take etcd snapshots, and manage their lifecycle from the UI.

---

!!! info "You Won't Install RKE2 Manually"
    On your downstream clusters, Rancher installs RKE2 for you when you run the registration command. You'll see this in action during the hands-on sections.
