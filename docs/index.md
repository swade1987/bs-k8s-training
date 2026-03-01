# CloudRISE Kubernetes Training

Welcome to the training guide for the **CloudRISE Kubernetes Foundation Programme**.

Over the course of this training, you'll build a production-grade Kubernetes platform from the ground up using **RKE2**, **Rancher**, and **Flux**.

---

## What You'll Build

By the end of this training, you will have:

- [x] A 3-node HA management cluster running **Rancher**
- [x] Your own 7-node downstream Kubernetes cluster
- [x] **Calico** CNI with MTU 9000 for jumbo frame support
- [x] **kubectl** access from your local workstation
- [x] **Flux** installed for GitOps-driven deployments
- [x] Your first application deployed via Git

---

## Training Structure

| Section | What You'll Learn |
|---------|------------------|
| **[1. Concepts](01-concepts/kubernetes.md)** | Kubernetes foundations, RKE2, Rancher architecture, GitOps |
| **[2. Management Cluster](02-management-cluster/index.md)** | Building the RKE2 + Rancher hub (Steve-led demo) |
| **[3. Downstream Clusters](03-downstream-clusters/index.md)** | Provisioning your own cluster through Rancher |
| **[4. Workstation Setup](04-workstation-setup/install-tools.md)** | Connecting kubectl from your local machine |
| **[5. GitOps with Flux](05-gitops/index.md)** | Installing Flux and deploying from Git |

---

## Quick Links

| Resource | URL |
|----------|-----|
| **Rancher Dashboard** | [https://steve.k.ma-no.si](https://steve.k.ma-no.si) |
| **SSH Key** | [http://store.ma-no.si/k/privatekey.ppk](http://store.ma-no.si/k/privatekey.ppk) |

---

!!! info "Follow Along"
    This site is your companion during the training. All commands are copy-paste ready — click the :material-content-copy: icon on any code block to copy it to your clipboard.
