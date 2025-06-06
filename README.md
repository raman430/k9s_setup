# 🚀 Kubernetes GitOps Lab Setup – Full Command History

> **User**: Kalyana Raman  
> **Generated**: June 02, 2025  
> **Platform**: Ubuntu (WSL2 on Windows)  

---

## 🧱 System Preparation

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git unzip vim gnupg software-properties-common apt-transport-https ca-certificates lsb-release
```

---

## 🐳 Docker Installation

```bash
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

---

## ☸️ Kubernetes CLI Tools

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version

# Start Minikube
minikube start --driver=docker
kubectl get nodes
```

---

## 📦 Helm + K9s

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# Install K9s
curl -s https://api.github.com/repos/derailed/k9s/releases/latest \
| grep "browser_download_url.*Linux_amd64.tar.gz" \
| cut -d '"' -f 4 | wget -i -
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
k9s
```

---

## 🔐 Git Setup

```bash
sudo apt install -y git
git config --global user.name "Kalyana Raman"
git config --global user.email "raman430@gmail.com"
```

---

## 🧾 SSH Key for GitHub

```bash
ssh-keygen -t ed25519 -C "raman430@gmail.com"
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

---

## 📁 Project Folder Setup

```bash
mkdir -p ~/projects/k9s_setup
cd ~/projects/k9s_setup
git init
code .
```

---

## 📦 Helm Chart + App Scaffold

```bash
helm create charts/myservice

# Create Flask app
mkdir app
echo '
from flask import Flask
app = Flask(__name__)
@app.route("/")
def home():
    return "Hello from K8s with Helm & GitOps!"
app.run(host="0.0.0.0", port=5000)
' > app/server.py

# Dockerfile
echo '
FROM python:3.9-slim
WORKDIR /app
COPY server.py .
RUN pip install flask
CMD ["python", "server.py"]
' > app/Dockerfile

# Build and push image
docker build -t <your-dockerhub-username>/myservice:latest ./app
docker push <your-dockerhub-username>/myservice:latest
```

---

## 🚀 Deploy with Helm

```bash
helm install myservice charts/myservice
kubectl get pods
kubectl get svc
```

---

## 🔁 Argo CD Setup

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd

# Port forward Argo CD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

---

## 🧾 Argo CD App YAML

```bash
mkdir gitops
cat <<EOF > gitops/myservice-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myservice
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/<your-username>/k9s_setup.git'
    targetRevision: HEAD
    path: charts/myservice
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Apply it
kubectl apply -f gitops/myservice-app.yaml
```

---

✅ Daily Checklist: Minikube + WSL Dev Environment

Before starting any Kubernetes development or testing with Minikube inside WSL, follow this checklist to ensure everything works smoothly.

✅ 1. Start Minikube

minikube start --driver=docker

✅ Ensure Docker is running before starting Minikube.

✅ 2. Start Minikube Tunnel (in a separate terminal)

minikube tunnel

✅ Required for ingress to route traffic. Keep this terminal open.

✅ 3. Fix /etc/hosts DNS mapping (Run Every Time WSL is Restarted)

echo '127.0.0.1 myservice.local' | sudo tee -a /etc/hosts > /dev/null

WSL overwrites /etc/hosts on every restart. You must reapply this.

✅ 4. (Optional One-Time) Prevent WSL from Overwriting /etc/hosts

sudo nano /etc/wsl.conf

Insert:

[network]
generateHosts = false

Then restart WSL:

wsl --shutdown

✅ Do this only if you're okay with manual /etc/hosts persistence.

✅ 5. Validate All Kubernetes Resources Are Running

kubectl get pods -o wide
kubectl get svc
kubectl get ingress

🔍 Check that pods are in Running state and ingress has an IP (127.0.0.1 usually).

✅ 6. Troubleshoot Failing Pods (CrashLoopBackOff)

Run:

kubectl describe pod <pod-name>
kubectl logs <pod-name>

Common Issues:

❌ Liveness/Readiness probe path mismatch (/healthz, /readyz) — return 404

❌ Wrong container port in service or ingress

✅ Fix by updating values.yaml:

livenessProbe:
  httpGet:
    path: /
    port: 5000
readinessProbe:
  httpGet:
    path: /
    port: 5000

✅ 7. Test Service Internally (from WSL)

curl http://myservice.local

Expected:

Hello from K8s with Helm & GitOps!

If you see 503, verify:

Minikube tunnel is running

Service points to correct target port (5000)

Ingress rule host/path matches the request

✅ 8. Access from Windows Browser

Since WSL networking is isolated, run:

minikube service myservice --url

✅ Copy the exposed URL (e.g., http://127.0.0.1:32287) and open it in Windows browser.

✅ 9. (Optional) Restart ArgoCD UI (If Installed)

kubectl port-forward svc/argocd-server -n argocd 8080:443

Then access in browser: https://localhost:8080

✅ 10. Helm Upgrade Reminder

If any chart file is updated (values.yaml, ingress.yaml, service.yaml):

helm upgrade --install myservice ./charts/myservice

Always re-run after updating chart templates or values.

