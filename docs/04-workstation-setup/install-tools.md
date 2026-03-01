# Install Local Tools

Install these tools on your **local machine** (laptop/desktop) to interact with your cluster.

---

## kubectl

=== "Windows (winget)"

    ```powershell
    winget install Kubernetes.kubectl
    ```

=== "Windows (Chocolatey)"

    ```powershell
    choco install kubernetes-cli
    ```

=== "macOS (Homebrew)"

    ```bash
    brew install kubectl
    ```

=== "Linux"

    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    ```

Verify:

```bash
kubectl version --client
```

---

## Helm (Recommended)

=== "Windows (winget)"

    ```powershell
    winget install Helm.Helm
    ```

=== "Windows (Chocolatey)"

    ```powershell
    choco install kubernetes-helm
    ```

=== "macOS (Homebrew)"

    ```bash
    brew install helm
    ```

=== "Linux"

    ```bash
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    ```

---

## SSH Client + Key

Download the private key:

```
http://store.ma-no.si/k/privatekey.ppk
```

!!! tip "Convert for OpenSSH (Linux/Mac)"
    ```bash
    puttygen privatekey.ppk -O private-openssh -o privatekey.pem
    chmod 600 privatekey.pem
    ```

---

## Create kubeconfig directory

```bash
mkdir -p ~/.kube
```
