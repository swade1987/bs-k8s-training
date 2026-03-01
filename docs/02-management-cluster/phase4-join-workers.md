# Phase 4 — Join Workers

!!! tip "Workers can join in parallel"
    Unlike masters, workers don't participate in etcd consensus. Run these steps on all 4 workers simultaneously.

---

## On Each Worker (k01w1–k01w4)

SSH into each worker:

```bash
ssh root@10.188.1.21   # k01w1
ssh root@10.188.1.22   # k01w2
ssh root@10.188.1.23   # k01w3
ssh root@10.188.1.31   # k01w4
```

### Create the agent config

```bash
mkdir -p /etc/rancher/rke2

cat > /etc/rancher/rke2/config.yaml << 'EOF'
server: https://10.188.1.11:9345
token: PASTE_YOUR_RKE2_TOKEN_HERE
EOF
```

### Install and start the RKE2 Agent

```bash
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=agent sh -
systemctl enable rke2-agent.service
systemctl start rke2-agent.service
```

!!! danger "Critical Difference"
    Workers use `INSTALL_RKE2_TYPE=agent` and `rke2-agent.service` — **not** `rke2-server`.

### Watch logs

```bash
journalctl -u rke2-agent -f
```

---

## Verify (from k01m1)

```bash
kubectl get nodes -o wide
```

Expected:
```
NAME    STATUS   ROLES                       AGE   VERSION          INTERNAL-IP
k01m1   Ready    control-plane,etcd,master   15m   v1.x.x+rke2r1   10.188.1.11
k01m2   Ready    control-plane,etcd,master   10m   v1.x.x+rke2r1   10.188.1.12
k01m3   Ready    control-plane,etcd,master   7m    v1.x.x+rke2r1   10.188.1.13
k01w1   Ready    <none>                      5m    v1.x.x+rke2r1   10.188.1.21
k01w2   Ready    <none>                      4m    v1.x.x+rke2r1   10.188.1.22
k01w3   Ready    <none>                      3m    v1.x.x+rke2r1   10.188.1.23
k01w4   Ready    <none>                      2m    v1.x.x+rke2r1   10.188.1.31
```

---

## Label Nodes

### Monitoring node (k01w4)

```bash
kubectl label node k01w4 node-role.kubernetes.io/monitoring=true
kubectl label node k01w4 dedicated=monitoring
kubectl taint node k01w4 dedicated=monitoring:NoSchedule
```

### Workers

```bash
kubectl label node k01w1 node-role.kubernetes.io/worker=true
kubectl label node k01w2 node-role.kubernetes.io/worker=true
kubectl label node k01w3 node-role.kubernetes.io/worker=true
```

---

## Verify Calico MTU 9000

```bash
# Calico pods running
kubectl get pods -n calico-system

# MTU set correctly
kubectl get installation default -o jsonpath='{.spec.calicoNetwork.mtu}'
echo ""
```

---

## Health Check

```bash
kubectl get pods -A | grep -v Completed
```

All pods should be `Running`.

✅ **All 7 nodes are up and healthy!**
