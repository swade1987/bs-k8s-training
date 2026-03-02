# Phase 0 — Generate the K3s Token

All nodes in the cluster share a single token for authentication. Generate it first.

```bash
openssl rand -base64 48
```

Save the output — this is your `K3S_TOKEN`. You'll use it when joining every node to the cluster.

!!! warning "Keep this token safe"
    Anyone with this token can join nodes to your cluster. Treat it like a password.
