#!/bin/bash

echo "=== Kubernetes Dev Environment Startup ==="

# Load environment variables
ENV_FILE="./env-config.env"
if [ -f "$ENV_FILE" ]; then
  export $(cat "$ENV_FILE" | xargs)
else
  echo "Missing $ENV_FILE file."
  exit 1
fi

# Function to check and install software
check_install() {
  if ! command -v $1 &> /dev/null; then
    echo "Installing $1..."
    sudo apt-get update && sudo apt-get install -y $2
  else
    echo "$1 already installed."
  fi
}

# Ensure required software is installed
check_install docker docker.io
check_install git git
check_install helm helm
check_install kubectl kubectl
check_install minikube minikube

# Start minikube
minikube start --driver=docker

# Patch /etc/hosts in WSL for ingress domains
for host in dev.myservice.local test.myservice.local prod.myservice.local; do
  if ! grep -q "$host" /etc/hosts; then
    echo "127.0.0.1 $host" | sudo tee -a /etc/hosts
  fi
done

# Start tunnel in background
pgrep -f "minikube tunnel" || nohup minikube tunnel > /dev/null 2>&1 &

# Install ArgoCD if not already
kubectl get ns argocd >/dev/null 2>&1 || kubectl create namespace argocd
kubectl get all -n argocd | grep argocd-server >/dev/null 2>&1 || kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Port-forward ArgoCD (start in background)
pgrep -f "kubectl port-forward svc/argocd-server" || kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &

# Retrieve ArgoCD password
ARGO_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "ArgoCD is running at: https://localhost:8080"
echo "Username: admin"
echo "Password: $ARGO_PASS"

# Delete and recreate namespaces
for ns in dev test prod; do
  echo "Resetting Helm namespace: $ns"
  kubectl delete ns $ns --ignore-not-found --wait=true
  kubectl create ns $ns
done

# Deploy Helm chart to each namespace
for ns in dev test prod; do
  echo "Deploying Helm chart to $ns"
  helm upgrade --install myservice-$ns ./charts/myservice -f ./charts/myservice/values-$ns.yaml --namespace $ns --create-namespace
done

echo "Application accessible at:"
echo "http://dev.myservice.local"
echo "http://test.myservice.local"
echo "http://prod.myservice.local"
