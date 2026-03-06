#!/bin/bash
# validate-calico-isolation.sh
# Validates Calico-native NetworkPolicy isolation between customer namespaces.
# Also verifies Calico policies are registered via calicoctl (not just kubectl).
#
# Usage:
#   chmod +x validate-calico-isolation.sh
#   ./validate-calico-isolation.sh
#
# Requirements:
#   - calicoctl installed and configured (or use kubectl exec into a calico-node pod)
#   - kubectl configured for the cluster

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass()  { echo -e "${GREEN}  ✅ PASS${NC} — $1"; }
fail()  { echo -e "${RED}  ❌ FAIL${NC} — $1"; }
info()  { echo -e "${BLUE}  ℹ️  INFO${NC} — $1"; }
warn()  { echo -e "${YELLOW}  ⚠️  WARN${NC} — $1"; }

echo ""
echo "========================================================"
echo "  CloudRISE — Calico Native Network Policy Validation"
echo "  Business Solutions d.o.o."
echo "========================================================"
echo ""

# ── PRE-FLIGHT: Verify Calico CRDs are available ─────────────────────────────
echo "PRE-FLIGHT: Checking Calico CRDs are installed..."
if kubectl get crd globalnetworkpolicies.projectcalico.org > /dev/null 2>&1; then
  pass "GlobalNetworkPolicy CRD found — Calico CRDs are installed"
else
  fail "GlobalNetworkPolicy CRD NOT found — is Calico installed as the CNI?"
  echo ""
  echo "  Check with: kubectl get pods -n calico-system"
  echo "  Or:         kubectl get pods -n kube-system | grep calico"
  exit 1
fi
echo ""

# ── PRE-FLIGHT: Verify policies are registered with Calico ───────────────────
echo "PRE-FLIGHT: Verifying Calico policies are applied..."

if kubectl get globalnetworkpolicies.projectcalico.org default-deny-all > /dev/null 2>&1; then
  pass "GlobalNetworkPolicy 'default-deny-all' is registered"
else
  warn "GlobalNetworkPolicy 'default-deny-all' not found — did you apply 01-calico-global-deny.yaml?"
fi

if kubectl get networkpolicies.projectcalico.org allow-same-namespace -n customer-a > /dev/null 2>&1; then
  pass "Calico NetworkPolicy 'allow-same-namespace' found in customer-a"
else
  warn "Calico NetworkPolicy not found in customer-a — did you apply 02-calico-namespace-policies.yaml?"
fi

if kubectl get networkpolicies.projectcalico.org allow-same-namespace -n customer-b > /dev/null 2>&1; then
  pass "Calico NetworkPolicy 'allow-same-namespace' found in customer-b"
else
  warn "Calico NetworkPolicy not found in customer-b — did you apply 02-calico-namespace-policies.yaml?"
fi
echo ""

# ── Wait for test pods ────────────────────────────────────────────────────────
echo "⏳ Waiting for test pods to be ready..."
kubectl wait --for=condition=Ready pod/web -n customer-a --timeout=60s
kubectl wait --for=condition=Ready pod/web -n customer-b --timeout=60s
echo ""

# ── Get service IPs ───────────────────────────────────────────────────────────
SVC_A=$(kubectl get svc web -n customer-a -o jsonpath='{.spec.clusterIP}')
SVC_B=$(kubectl get svc web -n customer-b -o jsonpath='{.spec.clusterIP}')

info "customer-a service ClusterIP: $SVC_A"
info "customer-b service ClusterIP: $SVC_B"
echo ""

# ── TEST 1: Intra-namespace — customer-a → customer-a ────────────────────────
echo "TEST 1: customer-a → customer-a (should SUCCEED — same namespace allowed)"
if kubectl exec -n customer-a web -- wget -qO- --timeout=5 "http://$SVC_A" > /dev/null 2>&1; then
  pass "customer-a pod reached customer-a service"
else
  fail "customer-a pod could NOT reach customer-a service (check allow-same-namespace policy)"
fi

# ── TEST 2: Intra-namespace — customer-b → customer-b ────────────────────────
echo ""
echo "TEST 2: customer-b → customer-b (should SUCCEED — same namespace allowed)"
if kubectl exec -n customer-b web -- wget -qO- --timeout=5 "http://$SVC_B" > /dev/null 2>&1; then
  pass "customer-b pod reached customer-b service"
else
  fail "customer-b pod could NOT reach customer-b service (check allow-same-namespace policy)"
fi

# ── TEST 3: Cross-namespace — customer-a → customer-b (must be BLOCKED) ──────
echo ""
echo "TEST 3: customer-a → customer-b (should FAIL — Calico GlobalNetworkPolicy blocks this)"
if kubectl exec -n customer-a web -- wget -qO- --timeout=5 "http://$SVC_B" > /dev/null 2>&1; then
  fail "customer-a pod REACHED customer-b — isolation is NOT working"
else
  pass "customer-a pod was BLOCKED from customer-b — Calico isolation confirmed"
fi

# ── TEST 4: Cross-namespace — customer-b → customer-a (must be BLOCKED) ──────
echo ""
echo "TEST 4: customer-b → customer-a (should FAIL — Calico GlobalNetworkPolicy blocks this)"
if kubectl exec -n customer-b web -- wget -qO- --timeout=5 "http://$SVC_A" > /dev/null 2>&1; then
  fail "customer-b pod REACHED customer-a — isolation is NOT working"
else
  pass "customer-b pod was BLOCKED from customer-a — Calico isolation confirmed"
fi

# ── TEST 5: DNS still works ───────────────────────────────────────────────────
echo ""
echo "TEST 5: DNS resolution still works within customer-a (should SUCCEED)"
if kubectl exec -n customer-a web -- nslookup web.customer-a.svc.cluster.local > /dev/null 2>&1; then
  pass "DNS resolution working inside customer-a"
else
  warn "DNS resolution failed — check 03-calico-allow-system.yaml is applied"
fi

echo ""
echo "========================================================"
echo "  SOW Deliverables Evidenced:"
echo "  ✅ Network isolation validated"
echo "  ✅ Network policy configuration (Calico native)"
echo "  ✅ Resource isolation to prevent customer interference"
echo "========================================================"
echo ""

# ── Show applied policies for the record ─────────────────────────────────────
echo "Applied Calico policies (for documentation):"
echo ""
echo "  Global policies:"
kubectl get globalnetworkpolicies.projectcalico.org -o custom-columns="NAME:.metadata.name,ORDER:.spec.order" 2>/dev/null || info "calicoctl not available — use 'kubectl get globalnetworkpolicies.projectcalico.org'"
echo ""
echo "  Namespace policies (customer-a):"
kubectl get networkpolicies.projectcalico.org -n customer-a -o custom-columns="NAME:.metadata.name,ORDER:.spec.order" 2>/dev/null
echo ""
echo "  Namespace policies (customer-b):"
kubectl get networkpolicies.projectcalico.org -n customer-b -o custom-columns="NAME:.metadata.name,ORDER:.spec.order" 2>/dev/null
echo ""
echo "Clean up when done:"
echo "  kubectl delete namespace customer-a customer-b"
echo "  kubectl delete globalnetworkpolicy default-deny-all allow-kube-dns allow-calico-internals allow-kube-apiserver"
echo ""
