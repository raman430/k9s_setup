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

🚀 Minikube + WSL Dev Environment: Daily Checklist

Keep your local Kubernetes development environment smooth and consistent with this curated checklist for WSL + Minikube users. Ideal for GitOps and Helm-based workflows.

🟢 1. Start Minikube

Ensure Docker is running, then start Minikube:

minikube start --driver=docker

🔄 2. Start Minikube Tunnel (in a separate terminal)

Required to expose services via Ingress:

minikube tunnel

Keep this running while working. It’s necessary for ingress traffic routing.

🛠 3. Fix /etc/hosts (Run after every WSL restart)

WSL resets /etc/hosts frequently. Add your custom hostname back:

echo '127.0.0.1 myservice.local' | sudo tee -a /etc/hosts > /dev/null

Re-run this daily unless step 4 is applied.

🧷 4. (Optional) Make /etc/hosts Persistent

Prevent WSL from regenerating /etc/hosts:

sudo nano /etc/wsl.conf

Paste:

[network]
generateHosts = false

Then shut down WSL:

wsl --shutdown

📦 5. Verify Kubernetes Resources

Ensure your cluster is healthy:

kubectl get pods
kubectl get svc
kubectl get ingress

🔍 6. Troubleshoot CrashLoopBackOff & Probes

Edit your Helm chart values:

livenessProbe:
  httpGet:
    path: /healthz
    port: 5000
readinessProbe:
  httpGet:
    path: /readyz
    port: 5000

Make sure your Flask app has these endpoints defined.

🧪 7. Test Endpoint Inside WSL

Check your app is running correctly:

curl http://myservice.local

Expected:

Hello from K8s with Helm & GitOps!

🌐 8. Access Service via Browser on Windows

minikube service myservice --url

Copy the output URL (e.g., http://127.0.0.1:5000) and open in your Windows browser.

🔁 9. Re-deploy Helm Chart (After Any Changes)

helm upgrade --install myservice ./charts/myservice

🧭 10. (Optional) Port-forward ArgoCD

kubectl port-forward svc/argocd-server -n argocd 8080:443

Then open: https://localhost:8080

✅ Summary

This checklist covers the real-world setup issues we've encountered and solved:

Ingress not resolving ➜ fixed via /etc/hosts

Service not reachable from browser ➜ use minikube service

Pod crashing ➜ liveness/readiness probe fixes

Ingress returning 503 ➜ correct targetPort, service port, and ingress host setup