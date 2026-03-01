# Self-Healing

This is where GitOps earns its keep. What happens when someone makes a manual change to the cluster?

---

## The Experiment

Git says podinfo should have **3 replicas**. Let's manually scale it down and see what Flux does.

### Step 1: Break it on purpose

```bash
kubectl scale deployment podinfo -n demo --replicas=1
```

Check:

```bash
kubectl get deployment podinfo -n demo
```

```
NAME      READY   UP-TO-DATE   AVAILABLE
podinfo   1/1     1            1
```

You just manually overrode what Git says should be deployed. This is called **drift.**

### Step 2: Watch Flux fix it

```bash
kubectl get deployment podinfo -n demo -w
```

Wait for the next reconciliation cycle (up to a few minutes). You'll see:

```
NAME      READY   UP-TO-DATE   AVAILABLE
podinfo   1/1     1            1           ← Your manual change
podinfo   1/3     1            1           ← Flux detected drift
podinfo   3/3     3            3           ← Flux restored the desired state
```

**Flux detected the difference between the cluster and Git, and corrected it automatically.**

### Step 3: Try deleting something

```bash
kubectl delete namespace demo
```

Watch:

```bash
kubectl get namespaces -w
```

Flux will recreate the entire namespace and everything in it — the deployment, the service, all of it. Because Git says it should exist.

---

## Why This Matters

In a traditional workflow:

- Someone scales down a deployment manually → nobody notices → app goes down
- Someone deletes a resource → it's gone → someone scrambles to recreate it
- Someone applies a quick fix directly → it's not documented → the next deploy overwrites it

With GitOps:

- **Manual changes get reverted.** The cluster always matches Git.
- **Deleted resources get recreated.** If Git says it exists, it exists.
- **Quick fixes don't stick.** If you want to change something, change it in Git.

!!! warning "This changes your workflow"
    Once Flux is running, `kubectl apply` and `kubectl edit` become **debugging tools**, not deployment tools. The only way to make a permanent change is through Git.

---

## Force Immediate Reconciliation

Don't want to wait for the next cycle? You can trigger it manually:

```bash
kubectl annotate --overwrite gitrepository flux-system -n flux-system \
  reconcile.fluxcd.io/requestedAt="$(date +%s)"
```

This tells the Source Controller to check Git immediately.

---

## Check Reconciliation Events

```bash
kubectl events -n flux-system --types=Normal
```

You'll see entries showing when Flux detected changes and what it applied.

Next: [Repository structure for production →](repo-structure.md)
