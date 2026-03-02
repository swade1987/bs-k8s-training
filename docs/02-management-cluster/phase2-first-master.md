# Phase 2 — First Server (k01m1)

SSH into k01m1:

```bash
ssh root@10.188.1.11
```

---

## 2.1 Install K3s (First Server — Initialises the Cluster)

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN="PASTE_YOUR_K3S_TOKEN_HERE" \
  INSTALL_K3S_EXEC="server \
    --cluster-init \
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

!!! warning "Replace the token"
    Replace `PASTE_YOUR_K3S_TOKEN_HERE` with the token from Phase 0.

| Flag | Why |
|------|-----|
| `--cluster-init` | Initialises a new HA cluster with embedded etcd |
| `--flannel-backend=none` | Disables Flannel — we're using Calico instead |
| `--disable-network-policy` | Disables K3s built-in network policy controller — Calico handles this |
| `--disable=traefik` | Disables built-in Traefik ingress — we manage our own |
| `--disable=servicelb` | Disables built-in service load balancer |
| `--tls-san` | API server certificate valid from all access points |
| `--write-kubeconfig-mode=644` | Makes kubeconfig readable without root |
| `--etcd-expose-metrics` | Enables Prometheus scraping of etcd |

---

## 2.2 Configure kubectl

```bash
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
source ~/.bashrc

kubectl get nodes
```

Expected:
```
NAME    STATUS     ROLES                       AGE   VERSION
k01m1   NotReady   control-plane,etcd,master   30s   v1.x.x+k3s1
```

!!! info "NotReady is expected"
    The node shows `NotReady` because there's no CNI installed yet. Flannel was disabled and Calico hasn't been deployed. That's the next step.

---

## 2.3 Install Calico

Install the Tigera operator and CRDs:

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/tigera-operator.yaml
```

Wait for the operator to be ready:

```bash
kubectl rollout status deployment tigera-operator -n tigera-operator
```

Create the Calico custom resources:

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/custom-resources.yaml
```

!!! tip "Calico version"
    Check [github.com/projectcalico/calico/releases](https://github.com/projectcalico/calico/releases) for the latest version. Replace `v3.29.3` if a newer stable release is available.

---

## 2.4 Wait for Calico and Node Ready

```bash
watch kubectl get pods -n calico-system
```

Once all Calico pods are Running:

```bash
kubectl get nodes
```

Expected:
```
NAME    STATUS   ROLES                       AGE   VERSION
k01m1   Ready    control-plane,etcd,master   3m    v1.x.x+k3s1
```

The node transitions from `NotReady` to `Ready` once Calico provides the CNI.

---

## 2.5 Verify

```bash
kubectl get pods -A
kubectl get pods -n calico-system
```

All pods should be `Running`.

First server is up with Calico!
