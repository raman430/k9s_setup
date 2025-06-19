#!/bin/bash

echo "=== Kubernetes Dev Environment Startup ==="

# Load configuration variables
CONFIG_FILE="./env-config.env"
if [ -f "$CONFIG_FILE" ]; then
    echo "[*] Loading environment config..."
    source "$CONFIG_FILE"
else
    echo "❌ Config file $CONFIG_FILE not found!"
    exit 1
fi

# Check required tools
echo "[*] Checking required tools..."
REQUIRED_TOOLS=("docker" "git" "helm" "kubectl" "minikube")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "❌ $tool is not installed."
        exit 1
    else
        echo "✓ $tool is installed."
    fi
done

# Start minikube
echo "[*] Starting Minikube..."
minikube start --driver=docker

# Update /etc/hosts entries (for WSL)
echo "[*] Updating /etc/hosts entries (for WSL environment only)..."
for ns in dev test prod; do
    LINE="127.0.0.1 $ns.myservice.local"
    if ! grep -Fxq "$LINE" /etc/hosts; then
        echo "$LINE" | sudo tee -a /etc/hosts > /dev/null
    fi
done

# Start Minikube tunnel (if not running)
if pgrep -f "minikube tunnel" > /dev/null; then
    echo "🔁 Minikube tunnel already running."
else
    echo "🚀 Starting Minikube tunnel in background..."
    nohup sudo minikube tunnel > /dev/null 2>&1 &
fi

# Port-forward ArgoCD
echo "🌐 Starting port-forward for ArgoCD..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &>/dev/null &
sleep 2

# ArgoCD credentials
echo "[*] Checking ArgoCD status..."
ARGO_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD is running at: https://localhost:8080"
echo "Username: admin"
echo "Password: $ARGO_PASS"

# Deploy helm apps
for ns in dev test prod; do
    echo "[*] Deploying Helm chart to $ns"
    RELEASE="myservice-$ns"
    # Uninstall release
    echo "➡️  Uninstalling existing release $RELEASE in $ns"
    helm uninstall "$RELEASE" -n "$ns" 2>/dev/null

    # Delete namespace and wait for cleanup
    echo "➡️  Deleting namespace $ns (to reset Helm metadata)"
    kubectl delete ns "$ns" --ignore-not-found
    echo "⏳ Waiting for namespace $ns to be fully terminated..."
    while kubectl get namespace "$ns" -o jsonpath="{.status.phase}" 2>/dev/null | grep -q .; do
        echo "   ↪️  Still terminating $ns ..."
        sleep 3
    done
    echo "✅ Namespace $ns is gone."

    echo "🚀 Installing $RELEASE into fresh namespace..."
    helm upgrade --install "$RELEASE" ./charts/myservice -f ./charts/myservice/values-$ns.yaml --namespace "$ns" --create-namespace
done

echo ""
echo "✅ Application accessible at:"
for ns in dev test prod; do
    echo "  http://$ns.myservice.local"
done

echo ""
echo "📢 NOTE:"
echo "  → Ensure 'minikube tunnel' stays running."
echo "  → Add hostnames to Windows hosts file if accessing from Windows browser."
echo "     (C:\Windows\System32\drivers\etc\hosts)"
