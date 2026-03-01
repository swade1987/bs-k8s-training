# CloudRISE Kubernetes Training

Training companion site for the **CloudRISE Kubernetes Foundation Programme** — delivered by Steve Wade Consulting for Business Solutions d.o.o.

## What This Is

A self-hosted MkDocs site that attendees follow along with during the training. Every command is copy-paste ready with real lab IPs, hostnames, and configuration.

## Topics Covered

- Kubernetes architecture fundamentals
- RKE2 cluster installation (CIS-hardened, Calico CNI, MTU 9000)
- Rancher multi-cluster management (hub and spoke)
- Downstream cluster provisioning via Rancher
- Workstation setup and kubeconfig distribution
- GitOps with Flux *(coming soon)*

## Lab Environment

- **9 clusters** (1 management + 8 attendee)
- **63 nodes** total (7 per lab)
- Ubuntu 24.04.4 LTS on Hyper-V
- Shared 10.188.0.0/16 network

## Running Locally

```bash
make serve
```

Then open [http://localhost:8000](http://localhost:8000).

## Structure

```
docs/
├── index.md                    # Home page
├── lab-environment.md          # IPs, hostnames, SSH access
├── 01-concepts/                # Theory — K8s, RKE2, Rancher, GitOps
├── 02-management-cluster/      # Lab 01 build (Steve-led demo)
├── 03-downstream-clusters/     # Attendee hands-on cluster creation
├── 04-workstation-setup/       # Local tools, kubeconfig, verification
└── 05-gitops/                  # Flux installation and first deployment
```

## Confidentiality

This repository contains environment-specific configuration for a private training engagement. Do not share publicly without permission.

---

*Prepared by Steve Wade Consulting — © 2026*
