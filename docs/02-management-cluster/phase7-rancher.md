# Phase 7 — Install Rancher

Run on **k01m1**:

---

## Install

```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --create-namespace \
  --set hostname=steve.k.ma-no.si \
  --set bootstrapPassword=KubeTraining2025! \
  --set replicas=3
```

## Wait for deployment

```bash
echo "Waiting for Rancher..."
kubectl rollout status deployment rancher -n cattle-system

# Watch all pods
watch kubectl get pods -n cattle-system
```

This takes 3-5 minutes. Wait until all rancher pods show `1/1 Running`.

## Verify

```bash
kubectl get pods -n cattle-system
kubectl get ingress -n cattle-system
```

---

## Access the Rancher UI

### Internal (from lab network)

```
https://10.188.1.11
```

or

```
https://steve.k.ma-no.si
```

!!! note "Certificate Warning"
    This is expected (self-signed cert).

    - **Chrome:** Type `thisisunsafe` on the warning page
    - **Firefox:** Click Advanced → Accept the Risk

### First Login

1. Enter bootstrap password: `KubeTraining2025!`
2. Set a new admin password when prompted
3. Verify the Server URL is `https://steve.k.ma-no.si`
4. Accept the terms and conditions

---

## Final Verification

```bash
echo "=== Nodes ==="
kubectl get nodes -o wide

echo ""
echo "=== Rancher Pods ==="
kubectl get pods -n cattle-system

echo ""
echo "=== cert-manager Pods ==="
kubectl get pods -n cert-manager

echo ""
echo "=== Cluster Info ==="
kubectl cluster-info
```

✅ **Rancher is running! You can now manage clusters from [https://steve.k.ma-no.si](https://steve.k.ma-no.si)**

---

## Troubleshooting

### Node won't join

```bash
journalctl -u rke2-server -f   # masters
journalctl -u rke2-agent -f    # workers

# Test connectivity
curl -k https://10.188.1.11:9345
```

### Need to start over on a node

```bash
/usr/local/bin/rke2-uninstall.sh        # server nodes
/usr/local/bin/rke2-agent-uninstall.sh   # agent nodes
```

### Rancher pods crashing

```bash
kubectl logs -n cattle-system -l app=rancher --tail=50
```

Usually cert-manager needs more time. Wait 2-3 minutes and check again.
