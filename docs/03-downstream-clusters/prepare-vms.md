# Prepare Your VMs

Run this on **all 7 of your VMs** before registering with Rancher.

---

## Quick Method: Loop From Your First Master

SSH into your first master, then run this loop:

!!! warning "Replace X with your lab number"
    For example, if you're Lab 04 (Damir), replace `X` with `4`.

```bash
for NODE in 10.188.X.11 10.188.X.12 10.188.X.13 10.188.X.21 10.188.X.22 10.188.X.23 10.188.X.31; do
  echo "====== Preparing $NODE ======"
  ssh root@$NODE 'bash -s' << 'PREP_EOF'

apt update && apt upgrade -y
apt install -y curl nfs-common open-iscsi
systemctl enable --now iscsid
systemctl stop ufw && systemctl disable ufw

mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/rke2-calico.conf << 'NM'
[keyfile]
unmanaged-devices=interface-name:flannel*;interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali
NM
systemctl reload NetworkManager 2>/dev/null || true

cat > /etc/modules-load.d/rke2.conf << 'MOD'
br_netfilter
overlay
MOD
modprobe br_netfilter && modprobe overlay

cat > /etc/sysctl.d/99-rke2.conf << 'SC'
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
SC
sysctl --system

echo "✅ Prepared $(hostname)"

PREP_EOF
done
```

---

## Alternative: SSH Into Each VM Individually

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

echo "✅ Prepared $(hostname)"
```

---

## Verify

```bash
for NODE in 10.188.X.11 10.188.X.12 10.188.X.13 10.188.X.21 10.188.X.22 10.188.X.23 10.188.X.31; do
  echo "=== $NODE ==="
  ssh root@$NODE 'echo "ip_forward: $(sysctl -n net.ipv4.ip_forward)" && echo "ufw: $(systemctl is-active ufw)"'
done
```

Expected: `ip_forward: 1` and `ufw: inactive` for each node.

---

## Test Connectivity to Rancher

```bash
curl -k https://10.188.1.11/healthz
```

Should return `ok`. If it times out, there's a network issue — flag it to Steve.
