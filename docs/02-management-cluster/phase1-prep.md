# Phase 1 — Prepare All Nodes

Run this on **all 7 nodes** before installing RKE2.

---

## What This Does

1. Updates the system and installs required packages
2. Disables UFW (Calico manages iptables directly)
3. Configures NetworkManager to ignore Calico interfaces
4. Loads required kernel modules
5. Sets sysctl parameters for Kubernetes networking

---

## Option A: Loop from a Single Machine

```bash
ALL_NODES="10.188.1.11 10.188.1.12 10.188.1.13 10.188.1.21 10.188.1.22 10.188.1.23 10.188.1.31"

for NODE in $ALL_NODES; do
  echo "====== Preparing $NODE ======"
  ssh root@$NODE 'bash -s' << 'PREP_EOF'

# Update and install packages
apt update && apt upgrade -y
apt install -y curl nfs-common open-iscsi
systemctl enable --now iscsid

# Disable UFW
systemctl stop ufw
systemctl disable ufw

# Configure NetworkManager to ignore Calico interfaces
mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/rke2-calico.conf << 'NM_EOF'
[keyfile]
unmanaged-devices=interface-name:flannel*;interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali
NM_EOF
systemctl reload NetworkManager 2>/dev/null || true

# Load kernel modules
cat > /etc/modules-load.d/rke2.conf << 'MOD_EOF'
br_netfilter
overlay
MOD_EOF
modprobe br_netfilter
modprobe overlay

# Set sysctl parameters
cat > /etc/sysctl.d/99-rke2.conf << 'SYSCTL_EOF'
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
SYSCTL_EOF
sysctl --system

echo "✅ Node preparation complete on $(hostname)"

PREP_EOF
done
```

---

## Option B: SSH Into Each Node

```bash
ssh root@10.188.1.11
```

Then paste:

```bash
apt update && apt upgrade -y
apt install -y curl nfs-common open-iscsi
systemctl enable --now iscsid
systemctl stop ufw && systemctl disable ufw

mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/rke2-calico.conf << 'EOF'
[keyfile]
unmanaged-devices=interface-name:flannel*;interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali
EOF
systemctl reload NetworkManager 2>/dev/null || true

cat > /etc/modules-load.d/rke2.conf << 'EOF'
br_netfilter
overlay
EOF
modprobe br_netfilter && modprobe overlay

cat > /etc/sysctl.d/99-rke2.conf << 'EOF'
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

echo "✅ Done on $(hostname)"
```

Repeat on all 7 nodes.

---

## Verify

```bash
for NODE in 10.188.1.11 10.188.1.12 10.188.1.13 10.188.1.21 10.188.1.22 10.188.1.23 10.188.1.31; do
  echo "=== $NODE ==="
  ssh root@$NODE 'echo "ip_forward: $(sysctl -n net.ipv4.ip_forward)" && echo "ufw: $(systemctl is-active ufw)"'
done
```

Expected per node: `ip_forward: 1` and `ufw: inactive`
