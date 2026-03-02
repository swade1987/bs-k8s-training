# Register Nodes

Once Steve has created your cluster and shared the registration commands, follow these steps.

---

## Step 1: First Master (Do This First!)

SSH into your **first master**:

```bash
ssh root@10.188.X.11    # X = your lab number
```

Paste the **control plane + etcd** registration command. It looks something like:

```bash
curl -fL https://steve.k.ma-no.si/system-agent-install.sh | sudo sh -s - \
  --server https://steve.k.ma-no.si \
  --label 'cattle.io/os=linux' \
  --token xxxxxxxxxxxxxxxx \
  --ca-checksum xxxxxxxx \
  --etcd --controlplane
```

!!! warning "Wait 3-5 minutes"
    The first master bootstraps the entire cluster. Watch the Rancher UI — your node will appear under the cluster's **Machines** tab.

    Status: `Waiting` → `Provisioning` → `Active`

---

## Step 2: Remaining Masters (One at a Time)

Once the first master appears in Rancher:

```bash
ssh root@10.188.X.12
# Paste the same control plane + etcd command

# Wait for it to appear in Rancher, then...

ssh root@10.188.X.13
# Paste the same control plane + etcd command
```

!!! danger "Wait for each master"
    Join masters **one at a time**. Wait for each to appear in Rancher before starting the next. etcd needs to form quorum properly.

---

## Step 3: Workers (All at Once)

Once all 3 masters are registered, run the **worker command** on all workers simultaneously:

```bash
ssh root@10.188.X.21    # Paste the worker command
ssh root@10.188.X.22    # Paste the worker command
ssh root@10.188.X.23    # Paste the worker command
ssh root@10.188.X.31    # Paste the worker command (monitoring node)
```

Workers can join in parallel — no need to wait between them.

---

## Step 4: Wait for Active

Watch the Rancher UI. Your cluster status will progress:

```
Waiting → Provisioning → Active ✅
```

When it says **Active**, your cluster is fully operational!

---

## What Happened Behind the Scenes

When you ran that registration command:

1. The **Rancher System Agent** installed on the node
2. The System Agent downloaded and installed **K3s**
3. The node bootstrapped Kubernetes
4. **cattle-cluster-agent** and **cattle-node-agent** deployed automatically
5. The agents opened a WebSocket tunnel back to Rancher
6. Rancher registered the node and started managing the cluster

All of this happened automatically — you didn't install K3s, configure etcd, or set up networking manually. Rancher handled it.

---

## Troubleshooting

### Node won't register / timeout

Most likely cause: your VM can't reach Rancher.

```bash
curl -k https://10.188.1.11/healthz
curl -k https://steve.k.ma-no.si/healthz
```

If the hostname doesn't resolve, add it:
```bash
echo "10.188.1.11 steve.k.ma-no.si" >> /etc/hosts
```

### Node stuck at "Waiting for probes"

Usually resolves in 2-3 minutes. If not:
```bash
journalctl -u rancher-system-agent -f
```

### Need to re-register a node

```bash
/usr/local/bin/k3s-uninstall.sh          # if it was a server node
/usr/local/bin/k3s-agent-uninstall.sh    # if it was an agent node

# Then re-run the registration command
```

### Registration command expired

Go back to the cluster in Rancher UI → **Registration** tab → copy a fresh command.
