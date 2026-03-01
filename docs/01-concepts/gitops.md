# GitOps & Flux

## What Is GitOps?

The core idea is simple: **Git is the single source of truth for your infrastructure and application configuration.**

Everything that should exist in your cluster is defined in a Git repository. A tool running inside your cluster watches that repository and automatically makes the cluster match what's in Git.

- **Deploy an app?** Commit a YAML file to Git. The tool picks it up and deploys it.
- **Change a config?** Update the file in Git. The tool applies the change.
- **Someone makes a manual change?** The tool detects the **drift** and reverts it to match Git.

---

## Why GitOps?

**Audit Trail**
:   Every change is a Git commit. You know who changed what, when, and why.

**Reproducibility**
:   You can recreate your entire cluster state from the Git repository at any time.

**Collaboration**
:   Changes go through pull requests. Review, discuss, and approve before anything is applied.

---

## Push vs Pull

There are two approaches:

| | Push-Based | Pull-Based |
|---|-----------|------------|
| **How** | CI pipeline pushes changes to the cluster | Agent inside the cluster pulls changes from Git |
| **Security** | CI needs access to the Kubernetes API | Nothing external needs cluster access |
| **Example** | Jenkins, GitHub Actions applying manifests | **Flux**, Argo CD |

**We're using pull-based.** It's more secure because nothing outside the cluster needs access to the Kubernetes API.

---

## What Is Flux?

**Flux** is a CNCF Graduated project — the same maturity level as Kubernetes itself. It runs inside your cluster as a set of controllers, each with a specific job:

**Source Controller**
:   Watches Git repositories (or Helm repos, or OCI registries) for changes. Pulls updated manifests when it detects a new commit.

**Kustomize Controller**
:   Takes manifests from the Source Controller and applies them to the cluster. Handles your standard Kubernetes YAML — Deployments, Services, ConfigMaps, etc.

**Helm Controller**
:   Manages Helm chart releases. If your app is packaged as a Helm chart, this installs and upgrades it.

**Notification Controller**
:   Sends alerts and receives webhooks. Can notify Slack on success/failure, or receive a webhook from GitHub to trigger immediate reconciliation.

---

## How It Works

```
Developer commits YAML to Git
        │
        ▼
┌─────────────────────────────────────────────────────┐
│  Your Kubernetes Cluster                            │
│                                                     │
│  Source Controller ─── polls Git every X minutes    │
│        │                                            │
│        ▼ (new commit detected)                      │
│                                                     │
│  Kustomize Controller ─── applies manifests         │
│        │                      OR                    │
│  Helm Controller ──── installs/upgrades charts      │
│        │                                            │
│        ▼                                            │
│  Kubernetes API ─── pods, services, etc. created    │
│                                                     │
│  Notification Controller ─── alerts on success/fail │
└─────────────────────────────────────────────────────┘
```

!!! important "Flux lives inside the cluster"
    It **pulls** from Git. Nothing outside the cluster needs to push to the Kubernetes API. This works naturally with firewalls and network policies.
