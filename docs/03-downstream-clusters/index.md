# Downstream Clusters (Labs 02–09)

!!! success "This is your hands-on section"
    You'll prep your VMs, register them with Rancher, and watch your cluster come to life.

---

## How It Works

1. **Steve** creates a custom cluster in Rancher for each attendee
2. **Rancher** generates a registration command
3. **You** run a prep script on all your VMs
4. **You** run the registration command on your VMs
5. **Rancher** installs K3s automatically and registers each node
6. The cluster goes **Active** in the Rancher UI

**You do NOT install K3s manually — Rancher does it for you.**

---

## Steps

| Step | What | Who |
|------|------|-----|
| [Prepare Your VMs](prepare-vms.md) | Install packages, configure networking | You |
| [Create Cluster in Rancher](create-cluster.md) | Create cluster, select Calico, get commands | Steve |
| [Register Nodes](register-nodes.md) | Run registration commands on your VMs | You |
| [Post-Registration](post-registration.md) | Configure Calico MTU, label nodes, get kubeconfig | You |

---

## Timeline

| Time | Activity |
|------|----------|
| 0:00 – 0:15 | Prep all 7 VMs |
| 0:15 – 0:25 | Steve creates clusters in Rancher, shares commands |
| 0:25 – 0:40 | Register first master, wait for it to appear |
| 0:40 – 0:55 | Join remaining masters (one at a time) |
| 0:55 – 1:10 | Join all workers (parallel) |
| 1:10 – 1:20 | Apply Calico MTU, label nodes |
| 1:20 – 1:30 | Download kubeconfig, verify access |
