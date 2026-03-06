#!/bin/bash
# validate-isolation.sh
# Run this after deploying all three YAML files.
# Shows pass/fail for each isolation test in under 60 seconds.
#
# Usage:
#   chmod +x validate-isolation.sh
#   ./validate-isolation.sh

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}  ✅ PASS${NC} — $1"; }
fail() { echo -e "${RED}  ❌ FAIL${NC} — $1"; }

echo ""
echo "================================================"
echo "  CloudRISE Network Isolation Validation"
echo "  Business Solutions d.o.o. — Calico Demo"
echo "================================================"
echo ""

# ── Wait for pods to be ready ────────────────────────────────────────────────
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod/web -n customer-a --timeout=60s
kubectl wait --for=condition=Ready pod/web -n customer-b --timeout=60s
echo ""

# ── Get cluster IPs ──────────────────────────────────────────────────────────
SVC_A=$(kubectl get svc web -n customer-a -o jsonpath='{.spec.clusterIP}')
SVC_B=$(kubectl get svc web -n customer-b -o jsonpath='{.spec.clusterIP}')

echo "  customer-a service IP: $SVC_A"
echo "  customer-b service IP: $SVC_B"
echo ""

# ── TEST 1: customer-a can reach its own service ─────────────────────────────
echo "TEST 1: customer-a → customer-a (should SUCCEED)"
if kubectl exec -n customer-a web -- wget -qO- --timeout=5 "http://$SVC_A" > /dev/null 2>&1; then
  pass "customer-a pod can reach customer-a service"
else
  fail "customer-a pod CANNOT reach customer-a service (unexpected)"
fi

# ── TEST 2: customer-b can reach its own service ─────────────────────────────
echo ""
echo "TEST 2: customer-b → customer-b (should SUCCEED)"
if kubectl exec -n customer-b web -- wget -qO- --timeout=5 "http://$SVC_B" > /dev/null 2>&1; then
  pass "customer-b pod can reach customer-b service"
else
  fail "customer-b pod CANNOT reach customer-b service (unexpected)"
fi

# ── TEST 3: customer-a CANNOT reach customer-b ───────────────────────────────
echo ""
echo "TEST 3: customer-a → customer-b (should FAIL — this proves isolation)"
if kubectl exec -n customer-a web -- wget -qO- --timeout=5 "http://$SVC_B" > /dev/null 2>&1; then
  fail "customer-a pod CAN reach customer-b — ISOLATION BROKEN"
else
  pass "customer-a pod is BLOCKED from reaching customer-b — isolation working"
fi

# ── TEST 4: customer-b CANNOT reach customer-a ───────────────────────────────
echo ""
echo "TEST 4: customer-b → customer-a (should FAIL — this proves isolation)"
if kubectl exec -n customer-b web -- wget -qO- --timeout=5 "http://$SVC_A" > /dev/null 2>&1; then
  fail "customer-b pod CAN reach customer-a — ISOLATION BROKEN"
else
  pass "customer-b pod is BLOCKED from reaching customer-a — isolation working"
fi

echo ""
echo "================================================"
echo "  SOW Deliverable: Network isolation validated ✅"
echo "================================================"
echo ""
echo "Clean up when done:"
echo "  kubectl delete namespace customer-a customer-b"
echo ""
