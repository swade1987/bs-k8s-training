# Phase 3 — Join Masters (k01m2, k01m3)

!!! warning "One at a time"
    Join masters **sequentially**. Wait for each to show `Ready` before starting the next. etcd needs quorum to form properly.

---

## Join k01m2

SSH into k01m2:

```bash
ssh root@10.188.1.12
```

### Config (points to k01m1)

```bash
mkdir -p /etc/rancher/rke2

cat > /etc/rancher/rke2/config.yaml << 'EOF'
server: https://10.188.1.11:9345
token: PASTE_YOUR_RKE2_TOKEN_HERE
cni: calico
tls-san:
  - 10.188.1.11
  - 10.188.1.12
  - 10.188.1.13
  - 10.188.1.100
  - steve.k.ma-no.si
  - 46.54.226.201
write-kubeconfig-mode: "0644"
etcd-expose-metrics: true
EOF
```

### Calico HelmChartConfig (same as k01m1)

```bash
mkdir -p /var/lib/rancher/rke2/server/manifests

cat > /var/lib/rancher/rke2/server/manifests/rke2-calico-config.yaml << 'EOF'
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

### Install and start

```bash
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
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

**Repeat the exact same steps** as k01m2 above.

---

## Final State

Verify from k01m1:

```bash
kubectl get nodes
```

Expected:
```
NAME    STATUS   ROLES                       AGE   VERSION
k01m1   Ready    control-plane,etcd,master   10m   v1.x.x+rke2r1
k01m2   Ready    control-plane,etcd,master   5m    v1.x.x+rke2r1
k01m3   Ready    control-plane,etcd,master   2m    v1.x.x+rke2r1
```

✅ **HA control plane is up! etcd has a 3-node quorum.**
