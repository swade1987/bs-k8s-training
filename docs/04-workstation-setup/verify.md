# Verify Access

With your kubeconfig set, verify everything works.

---

## Check Nodes

```bash
kubectl get nodes -o wide
```

You should see your 7 nodes — 3 masters, 3 workers, 1 monitoring — all `Ready`.

---

## Check Pods

```bash
kubectl get pods -A
```

All system pods should be `Running` or `Completed`.

---

## Check Cluster Info

```bash
kubectl cluster-info
```

---

## Quick Namespace Test

Create a test namespace to confirm you have write access:

```bash
kubectl create namespace test-access
kubectl get namespaces
kubectl delete namespace test-access
```

---

## Check Calico

```bash
kubectl get pods -n calico-system
kubectl get installation default -o jsonpath='{.spec.calicoNetwork.mtu}'
echo ""
```

MTU should show `9000`.

---

✅ **You now have full kubectl access to your cluster from your local machine!**

Next up: [GitOps with Flux](../05-gitops/index.md)
