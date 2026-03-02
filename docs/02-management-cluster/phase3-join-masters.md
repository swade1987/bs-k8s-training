# Phase 3 — Join Servers (k01m2, k01m3)

!!! warning "One at a time"
    Join servers **sequentially**. Wait for each to show `Ready` before starting the next. etcd needs quorum to form properly.

---

## Join k01m2

SSH into k01m2:

```bash
ssh root@10.188.1.12
```

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN="PASTE_YOUR_K3S_TOKEN_HERE" \
  INSTALL_K3S_EXEC="server \
    --server=https://10.188.1.11:6443 \
    --flannel-backend=none \
    --disable-network-policy \
    --disable=traefik \
    --disable=servicelb \
    --tls-san=10.188.1.11 \
    --tls-san=10.188.1.12 \
    --tls-san=10.188.1.13 \
    --tls-san=10.188.1.100 \
    --tls-san=steve.k.ma-no.si \
    --tls-san=46.54.226.201 \
    --write-kubeconfig-mode=644 \
    --etcd-expose-metrics" sh -
```

### Verify from k01m1

```bash
kubectl get nodes
```

Wait until k01m2 shows `Ready`.

---

## Join k01m3

SSH into k01m3:

```bash
ssh root@10.188.1.13
```

**Run the exact same command** as k01m2 above.

---

## Final State

Verify from k01m1:

```bash
kubectl get nodes
```

Expected:
```
NAME    STATUS   ROLES                       AGE   VERSION
k01m1   Ready    control-plane,etcd,master   10m   v1.x.x+k3s1
k01m2   Ready    control-plane,etcd,master   5m    v1.x.x+k3s1
k01m3   Ready    control-plane,etcd,master   2m    v1.x.x+k3s1
```

HA control plane is up! etcd has a 3-node quorum.
