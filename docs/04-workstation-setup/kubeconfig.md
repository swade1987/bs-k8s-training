# Get Your Kubeconfig

The kubeconfig file tells kubectl how to connect to your cluster. Download it from Rancher.

---

## Download from Rancher UI

1. Log into Rancher at [https://steve.k.ma-no.si](https://steve.k.ma-no.si)
2. Click **☰** → **Cluster Management**
3. Find your cluster
4. Click **⋮** (three dots) → **Download KubeConfig**
5. Save the file to `~/.kube/`

For example:

```bash
# Move the downloaded file
mv ~/Downloads/lab-04-damir.yaml ~/.kube/lab-04-damir.yaml
```

---

## Set the KUBECONFIG Environment Variable

=== "Linux / macOS"

    ```bash
    export KUBECONFIG=~/.kube/lab-04-damir.yaml
    ```

    To make it permanent, add to your `~/.bashrc` or `~/.zshrc`:

    ```bash
    echo 'export KUBECONFIG=~/.kube/lab-04-damir.yaml' >> ~/.bashrc
    source ~/.bashrc
    ```

=== "Windows (PowerShell)"

    ```powershell
    $env:KUBECONFIG = "$HOME\.kube\lab-04-damir.yaml"
    ```

    To make it permanent:

    ```powershell
    [Environment]::SetEnvironmentVariable("KUBECONFIG", "$HOME\.kube\lab-04-damir.yaml", "User")
    ```

---

## How This Works

The kubeconfig you download from Rancher routes through the **Rancher authentication proxy**:

```
Your laptop → steve.k.ma-no.si:443 → WebSocket tunnel → Your cluster
```

This means:

- ✅ Works from **anywhere** (home, office, VPN)
- ✅ Only needs to reach Rancher on **port 443**
- ✅ No direct access to your cluster's API server needed

!!! info "This is different from a direct kubeconfig"
    A direct kubeconfig would point to your cluster's API server on port 6443. The Rancher-proxied version is more convenient because it works from outside the lab network.
