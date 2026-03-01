# First GitOps Deployment

Flux is watching Git. Time to deploy something.

---

## The Workflow

From now on, **you don't run `kubectl apply` to deploy.** Instead:

1. Write your Kubernetes manifest
2. Commit it to the Git repository
3. Flux detects the change and applies it automatically

That's it. Git push = deploy.

---

## What's in the Repository

The training repository has this structure:

```
bs-fleet/
├── clusters/
│   └── training/
│       ├── namespaces/
│       │   └── demo.yaml
│       └── apps/
│           └── podinfo/
│               ├── namespace.yaml
│               ├── deployment.yaml
│               └── service.yaml
```

Flux is watching `clusters/training/`. Anything in that directory gets applied to your cluster.

---

## Watch It Happen

### Step 1: Check what Flux is syncing

```bash
kubectl get kustomization -n flux-system
```

This shows the sync status. `Ready: True` means Flux has successfully applied everything from Git.

### Step 2: See what was deployed

```bash
kubectl get namespaces
```

You should see a `demo` namespace that didn't exist before — Flux created it from the repository.

```bash
kubectl get all -n demo
```

You should see the `podinfo` deployment and service running.

### Step 3: Access the app

```bash
kubectl port-forward -n demo svc/podinfo 9898:9898
```

Open [http://localhost:9898](http://localhost:9898) in your browser. You should see the podinfo UI.

Press `Ctrl+C` to stop port-forwarding.

---

## Make a Change via Git

Now the powerful part. Let's change the application **without touching kubectl.**

### Step 1: Steve pushes a change to the repository

Steve will update the `deployment.yaml` to change the replica count from 1 to 3.

### Step 2: Watch Flux pick it up

```bash
# Watch the deployment in real-time
kubectl get deployment podinfo -n demo -w
```

Within a few minutes (the default reconciliation interval), you'll see:

```
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
podinfo   1/1     1            1           5m
podinfo   1/3     1            1           6m     ← Flux detected the change
podinfo   1/3     3            1           6m     ← New pods starting
podinfo   3/3     3            3           6m     ← All replicas running
```

### Step 3: Verify

```bash
kubectl get pods -n demo
```

Three pods instead of one. **Nobody ran kubectl. Git was the only interface.**

---

## What Just Happened

```
Steve changes replicas: 1 → 3 in Git
         │
         ▼
Source Controller detects new commit
         │
         ▼
Kustomize Controller applies updated manifest
         │
         ▼
Kubernetes scales podinfo from 1 to 3 replicas
         │
         ▼
You see 3 pods running — without touching kubectl
```

!!! tip "This is GitOps"
    The cluster state always matches what's in Git. The Git repository is the single source of truth. If you want to know what's deployed, look at Git — not the cluster.

Next: [Watch Flux self-heal →](self-healing.md)
