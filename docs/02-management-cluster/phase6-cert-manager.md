# Phase 6 — Install cert-manager

Run on **k01m1**:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

## Wait for readiness

```bash
echo "Waiting for cert-manager..."
kubectl rollout status deployment cert-manager -n cert-manager
kubectl rollout status deployment cert-manager-webhook -n cert-manager
kubectl rollout status deployment cert-manager-cainjector -n cert-manager
```

## Verify

```bash
kubectl get pods -n cert-manager
```

All 3 pods should be `Running`.

!!! info "Why cert-manager?"
    Rancher uses cert-manager to automatically generate and manage TLS certificates. Without it, Rancher can't serve HTTPS.
