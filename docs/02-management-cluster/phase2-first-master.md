# Phase 2 — First Master (k01m1)

SSH into k01m1:

```bash
ssh root@10.188.1.11
```

---

## 2.1 Create the RKE2 Config

```bash
mkdir -p /etc/rancher/rke2

cat > /etc/rancher/rke2/config.yaml << 'EOF'
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

!!! warning "Replace the token"
    Replace `PASTE_YOUR_RKE2_TOKEN_HERE` with the token from Phase 0.

| Config Key | Why |
|-----------|-----|
| `cni: calico` | Use Calico instead of default Canal |
| `tls-san` | API server certificate is valid from all access points |
| `write-kubeconfig-mode` | Makes kubeconfig readable without root |
| `etcd-expose-metrics` | Enables Prometheus scraping of etcd |

---

## 2.2 Create the Calico HelmChartConfig (MTU 9000)

!!! danger "This MUST be created BEFORE starting RKE2"
    RKE2 auto-deploys any manifests in this directory on first boot. If Calico starts with the wrong MTU, you'll need to restart.

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

> **Why MTU 9000?** The Hyper-V network supports jumbo frames. Matching Calico's MTU avoids fragmentation and improves pod-to-pod throughput.

---

## 2.3 Install and Start RKE2

```bash
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
```

## 2.4 Watch the Logs

```bash
journalctl -u rke2-server -f
```

Wait until you see the node registered (2-3 minutes). Press `Ctrl+C` to exit.

---

## 2.5 Configure kubectl

```bash
echo 'export PATH=$PATH:/var/lib/rancher/rke2/bin' >> ~/.bashrc
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc
source ~/.bashrc

ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl

kubectl get nodes
```

Expected:
```
NAME    STATUS   ROLES                       AGE   VERSION
k01m1   Ready    control-plane,etcd,master   2m    v1.x.x+rke2r1
```

✅ **First master is up!**
