# Post-Registration Setup

Once your cluster is **Active**, there are a few configuration steps to complete.

---

## 1. Configure Calico MTU 9000

Open the **kubectl Shell** for your cluster in Rancher (top-right button), then run:

```bash
cat << 'EOF' | kubectl apply -f -
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-calico
  namespace: kube-system
spec:
  valuesContent: |-
    installation:
      calicoNetwork:
        mtu: 9000
EOF
```

Wait for Calico to reconcile (1-2 minutes):

```bash
kubectl get pods -n calico-system -w
```

Verify:

```bash
kubectl get installation default -o jsonpath='{.spec.calicoNetwork.mtu}'
echo ""
# Should output: 9000
```

---

## 2. Label the Monitoring Node

Replace `X` with your lab number (e.g., `k04w4` for Lab 04):

```bash
kubectl label node k0Xw4 node-role.kubernetes.io/monitoring=true
kubectl label node k0Xw4 dedicated=monitoring
kubectl taint node k0Xw4 dedicated=monitoring:NoSchedule
```

---

## 3. Label Workers

```bash
kubectl label node k0Xw1 node-role.kubernetes.io/worker=true
kubectl label node k0Xw2 node-role.kubernetes.io/worker=true
kubectl label node k0Xw3 node-role.kubernetes.io/worker=true
```

---

## 4. Verify Everything

```bash
kubectl get nodes -o wide
```

You should see all 7 nodes as `Ready` with proper roles assigned.

```bash
kubectl get pods -A | grep -v Completed
```

All pods should be `Running`.

---

## Final State

When all attendees have completed these steps, the Rancher dashboard should show:

```
Cluster                    Status    Provider    Nodes
─────────────────────────────────────────────────────
local                      Active    RKE2        7      ← Management cluster
lab-02-aleksander          Active    Custom      7
lab-03-ales                Active    Custom      7
lab-04-damir               Active    Custom      7
lab-05-erikp               Active    Custom      7
lab-06-eriks               Active    Custom      7
lab-07-luka                Active    Custom      7
lab-08-nejc                Active    Custom      7
lab-09-sani                Active    Custom      7
```

**9 clusters, 63 nodes — all managed from a single Rancher dashboard.** :tada:
