# Phase 4 — Join Agents

!!! tip "Agents can join in parallel"
    Unlike servers, agents don't participate in etcd consensus. Run these on all 4 agents simultaneously.

---

## On Each Agent (k01w1-k01w4)

SSH into each agent:

```bash
ssh root@10.188.1.21   # k01w1
ssh root@10.188.1.22   # k01w2
ssh root@10.188.1.23   # k01w3
ssh root@10.188.1.31   # k01w4
```

### Install the K3s Agent

```bash
curl -sfL https://get.k3s.io | K3S_URL="https://10.188.1.11:6443" \
  K3S_TOKEN="PASTE_YOUR_K3S_TOKEN_HERE" sh -
```

Two environment variables. One curl command. The agent downloads, installs, and joins the cluster automatically.

### Watch logs

```bash
journalctl -u k3s-agent -f
```

---

## Verify (from k01m1)

```bash
kubectl get nodes -o wide
```

Expected:
```
NAME    STATUS   ROLES                       AGE   VERSION          INTERNAL-IP
k01m1   Ready    control-plane,etcd,master   15m   v1.x.x+k3s1     10.188.1.11
k01m2   Ready    control-plane,etcd,master   10m   v1.x.x+k3s1     10.188.1.12
k01m3   Ready    control-plane,etcd,master   7m    v1.x.x+k3s1     10.188.1.13
k01w1   Ready    <none>                      3m    v1.x.x+k3s1     10.188.1.21
k01w2   Ready    <none>                      3m    v1.x.x+k3s1     10.188.1.22
k01w3   Ready    <none>                      3m    v1.x.x+k3s1     10.188.1.23
k01w4   Ready    <none>                      2m    v1.x.x+k3s1     10.188.1.31
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

## Health Check

```bash
kubectl get pods -A | grep -v Completed
```

All pods should be `Running`.

All 7 nodes are up and healthy!
