# Lab Environment

## Network Overview

All labs share a common **10.188.0.0/16** network. Every VM can reach every other VM across all labs.

```
Public IPs (46.54.226.20X) ──→ DST-NAT ──→ Internal Network (10.188.X.0/24)
```

---

## Lab Assignments

| Lab | Attendee | Public IP | Hostname | Internal Subnet |
|-----|----------|-----------|----------|-----------------|
| 01 | Steve (Management) | 46.54.226.201 | steve.k.ma-no.si | 10.188.1.0/24 |
| 02 | Aleksander | 46.54.226.202 | aleksander.k.ma-no.si | 10.188.2.0/24 |
| 03 | Aleš | 46.54.226.203 | ales.k.ma-no.si | 10.188.3.0/24 |
| 04 | Damir | 46.54.226.204 | damir.k.ma-no.si | 10.188.4.0/24 |
| 05 | ErikP | 46.54.226.205 | erikp.k.ma-no.si | 10.188.5.0/24 |
| 06 | ErikS | 46.54.226.206 | eriks.k.ma-no.si | 10.188.6.0/24 |
| 07 | Luka | 46.54.226.207 | luka.k.ma-no.si | 10.188.7.0/24 |
| 08 | Nejc | 46.54.226.208 | nejc.k.ma-no.si | 10.188.8.0/24 |
| 09 | Sani | 46.54.226.209 | sani.k.ma-no.si | 10.188.9.0/24 |

---

## Nodes Per Lab

Every lab has **7 VMs** running Ubuntu 24.04.4 LTS on Hyper-V:

| Hostname Pattern | Internal IP | Role |
|-----------------|-------------|------|
| k**XX**m1 | 10.188.**X**.11 | Control Plane + etcd |
| k**XX**m2 | 10.188.**X**.12 | Control Plane + etcd |
| k**XX**m3 | 10.188.**X**.13 | Control Plane + etcd |
| k**XX**w1 | 10.188.**X**.21 | Worker |
| k**XX**w2 | 10.188.**X**.22 | Worker |
| k**XX**w3 | 10.188.**X**.23 | Worker |
| k**XX**w4 | 10.188.**X**.31 | Monitoring (dedicated worker) |

Replace **XX** with your two-digit lab number and **X** with your lab number.

!!! example "Example: Lab 04 (Damir)"
    - `k04m1` = 10.188.4.11 (master 1)
    - `k04w2` = 10.188.4.22 (worker 2)
    - `k04w4` = 10.188.4.31 (monitoring node)

---

## SSH Access

### From Inside the Lab Network

```bash
ssh root@10.188.X.11    # replace X with your lab number
```

### From External / Home

```bash
ssh -i privatekey.ppk root@46.54.226.20X -p 40YY
```

Where:

- **X** = lab number (1-9)
- **YY** = node identifier (11, 12, 13 for masters; 21, 22, 23 for workers; 31 for monitoring)

!!! example "Example: SSH to Lab 04 master 2 from home"
    ```bash
    ssh -i privatekey.ppk root@46.54.226.204 -p 4012
    ```

### SSH Key Download

Download the private key from: [http://store.ma-no.si/k/privatekey.ppk](http://store.ma-no.si/k/privatekey.ppk)

!!! warning "PuTTY Key Format"
    The `.ppk` file is in PuTTY format. If you're using OpenSSH (Linux/Mac/Windows Terminal), convert it first:
    ```bash
    # Install putty-tools if needed
    sudo apt install putty-tools    # Linux
    brew install putty               # Mac

    # Convert .ppk to OpenSSH format
    puttygen privatekey.ppk -O private-openssh -o privatekey.pem
    chmod 600 privatekey.pem

    # Then use:
    ssh -i privatekey.pem root@46.54.226.20X -p 40YY
    ```

---

## Key URLs

| Resource | URL | Notes |
|----------|-----|-------|
| Rancher Dashboard | [https://steve.k.ma-no.si](https://steve.k.ma-no.si) | Management UI for all clusters |
| SSH Key | [http://store.ma-no.si/k/privatekey.ppk](http://store.ma-no.si/k/privatekey.ppk) | PuTTY format |
