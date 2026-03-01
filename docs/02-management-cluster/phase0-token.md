# Phase 0 — Generate the RKE2 Token

All nodes in the cluster share a single token for authentication. Generate it first.

```bash
openssl rand -base64 48
```

Save the output — this is your `RKE2_TOKEN`. You'll use it in every config file.

!!! warning "Keep this token safe"
    Anyone with this token can join nodes to your cluster. Treat it like a password.
