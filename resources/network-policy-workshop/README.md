# Kubernetes Network Policy Demo: Tenant Isolation with Calico

## What This Delivers

This repository demonstrates and validates multi-tenant namespace isolation on Kubernetes — the platform-level guarantee that one customer's workloads cannot interfere with, or access data from, another customer's workloads.

| SOW Deliverable | How It's Validated |
|---|---|
| Resource isolation to prevent customer interference | Cross-namespace traffic is blocked and tested (Tests 3 & 4) |
| Network policy configuration | Policies applied using both Kubernetes-native and Calico-native APIs |
| Network isolation validated | Automated pass/fail validation script with explicit output |

Run the validation script at the end of this guide and the output directly evidences these three deliverables.

---

## Why This Matters for Business Solutions

Business Solutions operates a multi-tenant platform where a single Kubernetes cluster hosts workloads for multiple customers simultaneously. Without network policy:

- A misconfigured application in one customer's namespace can make requests to services in another customer's namespace
- A noisy or misbehaving tenant can saturate shared network resources and degrade others
- There is no platform-level enforcement of isolation — it relies entirely on application-level correctness

Network policy moves isolation enforcement down to the infrastructure layer. It doesn't matter if an application is misconfigured or compromised — the platform itself blocks the traffic before it arrives.

For a platform serving customers ranging from SMBs to enterprise deployments, this is a non-negotiable foundation. It's also the prerequisite for multi-tenancy on DMS v2.

---

## Two Implementations — Which One to Use

This repository contains two approaches to network policy. They solve the same problem differently.

### `k8s-network-policy/` — Standard Kubernetes NetworkPolicy

Uses the built-in `networking.k8s.io/v1` API that ships with every Kubernetes cluster.

**Works with:** Any CNI plugin that supports NetworkPolicy (Calico, Cilium, Weave, and others).

**Limitation:** Policies are scoped per namespace. A default-deny rule must be manually created in every new namespace. If a namespace is created without one, it has no isolation until someone notices and fixes it.

### `calico-native-policy/` — Calico Native NetworkPolicy

Uses Calico's own `projectcalico.org/v3` CRDs — `GlobalNetworkPolicy` and `NetworkPolicy`.

**Works with:** Clusters where Calico is the CNI (which is the case for this deployment).

**Advantage:** The `GlobalNetworkPolicy` resource applies cluster-wide. New namespaces are isolated by default the moment they are created — no manual intervention required. This is the recommended approach for this platform.

---

## Understanding Calico Network Policy

This section explains how Calico's policy model works. It is worth understanding before applying the policies, because the order of operations matters.

### How Calico Differs from Standard Kubernetes NetworkPolicy

Standard Kubernetes NetworkPolicy works by **addition** — you add rules to allow traffic, and anything without a rule is denied only if a default-deny policy also exists in that namespace.

Calico's model adds two important capabilities:

**1. GlobalNetworkPolicy**

A `GlobalNetworkPolicy` applies to every pod in every namespace across the entire cluster. You define it once. Every namespace — including ones created in the future — inherits it automatically.

This is the correct model for a multi-tenant platform. The alternative (per-namespace deny policies) requires operational discipline to maintain. Humans forget. The platform should not rely on humans remembering.

**2. Explicit Allow and Deny Actions**

Standard Kubernetes NetworkPolicy never says `deny` explicitly — it denies by omission. If there is no rule permitting traffic, it is dropped silently.

Calico policies use explicit `action: Allow` and `action: Deny` statements. This makes policies easier to read, easier to audit, and easier to reason about when something is not working as expected.

### The Order Field

Every Calico policy has an `order` field. Calico evaluates policies in ascending order — lower numbers are evaluated first.

This matters because policies can conflict. The order field gives you control over which policy wins when they do.

This demo uses the following order structure:

| Order | Policy | Purpose |
|---|---|---|
| `10` | `allow-kube-dns` | CoreDNS must resolve service names — this must be permitted before any deny applies |
| `10` | `allow-calico-internals` | Calico's own components (Felix, IPAM) need to communicate to enforce policy |
| `10` | `allow-kube-apiserver` | Controllers and operators that communicate with the Kubernetes API server |
| `100` | `allow-same-namespace` | Permits traffic between pods within the same customer namespace |
| `1000` | `default-deny-all` | Catches and drops everything not explicitly permitted above |

Think of it as a waterfall. Traffic hits order 10 rules first. If it matches, the action is taken and evaluation stops. If it doesn't match, it falls through to order 100, then 1000. The default-deny at 1000 is the floor — it catches everything that wasn't explicitly allowed above it.

### Why the Apply Order Matters

When applying these policies to a live cluster, the **system allow rules must be applied before the global deny**.

If you apply the global deny first, Calico immediately starts enforcing it. In the gap between applying the deny and applying the system allows, kube-dns stops working, Calico's own health checks fail, and the cluster enters a degraded state.

Applying the allows first means there is never a gap — by the time the deny is active, the permits are already in place.

---

## Prerequisites

- Kubernetes cluster with Calico installed as the CNI
- `kubectl` configured and pointing at the cluster
- Verify Calico CRDs are available:

```bash
kubectl get crd globalnetworkpolicies.projectcalico.org
```

If this returns an error, Calico is not installed or its CRDs are not registered.

---

## Repository Structure

```
.
├── README.md
│
├── k8s-network-policy/
│   ├── 01-namespaces.yaml            # customer-a and customer-b namespaces
│   ├── 02-network-policies.yaml      # Default-deny + same-namespace allow
│   ├── 03-test-workloads.yaml        # nginx pods and services for testing
│   └── validate-isolation.sh         # Pass/fail validation script
│
└── calico-native-policy/
    ├── 01-calico-global-deny.yaml         # GlobalNetworkPolicy: cluster-wide default-deny
    ├── 02-calico-namespace-policies.yaml  # Per-tenant allow rules
    ├── 03-calico-allow-system.yaml        # kube-dns, Calico internals, kube-apiserver
    ├── 04-test-workloads.yaml             # nginx pods and services for testing
    └── validate-calico-isolation.sh       # Pass/fail validation script with CRD checks
```

---

## Quick Start: Standard Kubernetes NetworkPolicy

```bash
cd k8s-network-policy

kubectl apply -f 01-namespaces.yaml
kubectl apply -f 02-network-policies.yaml
kubectl apply -f 03-test-workloads.yaml

chmod +x validate-isolation.sh
./validate-isolation.sh
```

Expected output:

```
TEST 1: customer-a → customer-a (should SUCCEED)
  ✅ PASS — customer-a pod can reach customer-a service

TEST 2: customer-b → customer-b (should SUCCEED)
  ✅ PASS — customer-b pod can reach customer-b service

TEST 3: customer-a → customer-b (should FAIL — proves isolation)
  ✅ PASS — customer-a pod is BLOCKED from reaching customer-b

TEST 4: customer-b → customer-a (should FAIL — proves isolation)
  ✅ PASS — customer-b pod is BLOCKED from reaching customer-a
```

---

## Quick Start: Calico-Native NetworkPolicy

Before applying, verify your kube-apiserver ClusterIP:

```bash
kubectl get svc kubernetes -n default -o jsonpath='{.spec.clusterIP}'
```

If the result is not `10.96.0.1`, update the `nets` field in `03-calico-allow-system.yaml` before continuing.

```bash
cd calico-native-policy

kubectl apply -f 04-test-workloads.yaml             # namespaces and test pods
kubectl apply -f 03-calico-allow-system.yaml        # system allows FIRST
kubectl apply -f 01-calico-global-deny.yaml         # global deny second
kubectl apply -f 02-calico-namespace-policies.yaml  # per-tenant allow rules

chmod +x validate-calico-isolation.sh
./validate-calico-isolation.sh
```

Expected output:

```
PRE-FLIGHT: Checking Calico CRDs are installed...
  ✅ PASS — GlobalNetworkPolicy CRD found

PRE-FLIGHT: Verifying Calico policies are applied...
  ✅ PASS — GlobalNetworkPolicy 'default-deny-all' is registered
  ✅ PASS — Calico NetworkPolicy 'allow-same-namespace' found in customer-a
  ✅ PASS — Calico NetworkPolicy 'allow-same-namespace' found in customer-b

TEST 1: customer-a → customer-a (should SUCCEED)
  ✅ PASS — customer-a pod reached customer-a service

TEST 2: customer-b → customer-b (should SUCCEED)
  ✅ PASS — customer-b pod reached customer-b service

TEST 3: customer-a → customer-b (should FAIL — Calico GlobalNetworkPolicy blocks this)
  ✅ PASS — customer-a pod was BLOCKED from customer-b

TEST 4: customer-b → customer-a (should FAIL — Calico GlobalNetworkPolicy blocks this)
  ✅ PASS — customer-b pod was BLOCKED from customer-a

TEST 5: DNS resolution still works within customer-a (should SUCCEED)
  ✅ PASS — DNS resolution working inside customer-a
```

---

## Adding a New Tenant Namespace

When a new customer namespace is created, the `GlobalNetworkPolicy` default-deny applies to it automatically. No changes to existing policies are needed.

The only thing required is a same-namespace allow policy for the new tenant:

```yaml
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: customer-c          # update to new namespace name
spec:
  order: 100
  selector: all()
  types:
    - Ingress
    - Egress
  ingress:
    - action: Allow
      source:
        namespaceSelector: projectcalico.org/name == 'customer-c'   # update here
  egress:
    - action: Allow
      destination:
        namespaceSelector: projectcalico.org/name == 'customer-c'   # and here
    - action: Allow
      protocol: UDP
      destination:
        ports: [53]
    - action: Allow
      protocol: TCP
      destination:
        ports: [53]
```

This pattern should be templated into the namespace provisioning process so it is applied automatically whenever a new tenant namespace is created.

---

## Clean Up

```bash
# Standard Kubernetes NetworkPolicy
kubectl delete namespace customer-a customer-b

# Calico native — also remove global policies
kubectl delete namespace customer-a customer-b
kubectl delete globalnetworkpolicy default-deny-all allow-kube-dns allow-calico-internals allow-kube-apiserver
```

---

## Further Reading

- [Calico NetworkPolicy documentation](https://docs.tigera.io/calico/latest/network-policy/get-started/calico-policy/calico-network-policy)
- [Calico GlobalNetworkPolicy reference](https://docs.tigera.io/calico/latest/reference/resources/globalnetworkpolicy)
- [Kubernetes NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network policy recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)
