# Create Cluster in Rancher

!!! info "Steve does this step"
    Steve creates a cluster for each attendee in the Rancher UI. Watch the screen to see the process.

---

## Steps (Per Attendee)

1. Log into Rancher at [https://steve.k.ma-no.si](https://steve.k.ma-no.si)
2. Click **☰** → **Cluster Management**
3. Click **Create**
4. Under "Use existing nodes and create a cluster using RKE2/K3s", click **Custom**
5. Fill in:

| Field | Value |
|-------|-------|
| **Cluster Name** | `lab-XX-name` (e.g., `lab-02-aleksander`) |
| **Kubernetes Version** | Latest stable RKE2 |
| **Container Network** | **Calico** :material-alert: Not Canal |

6. Click **Create**

---

## Cluster Names

| Cluster Name | Attendee |
|-------------|----------|
| `lab-02-aleksander` | Aleksander |
| `lab-03-ales` | Aleš |
| `lab-04-damir` | Damir |
| `lab-05-erikp` | ErikP |
| `lab-06-eriks` | ErikS |
| `lab-07-luka` | Luka |
| `lab-08-nejc` | Nejc |
| `lab-09-sani` | Sani |

---

## Registration Commands

After creating each cluster, Rancher shows the **Registration** page with commands.

**For master nodes** (control plane + etcd):

- [x] etcd
- [x] Control Plane
- [ ] Worker
- [x] Insecure (self-signed certs)

**For worker nodes:**

- [ ] etcd
- [ ] Control Plane
- [x] Worker
- [x] Insecure (self-signed certs)

Steve will share your two commands (master + worker) so you can run them on your VMs.
