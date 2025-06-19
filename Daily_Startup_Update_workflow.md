Daily Startup + Update Workflow (WSL)

🧰 Step 0: Run the Cluster Startup Script
```
cd ~/projects/k9s_setup
./cluster-startup.sh
```
✅ Step 1: Check Argo CD Status
```
kubectl get pods -n argocd
kubectl rollout restart deployment argocd-server -n argocd
```
🌐 Step 2: Port-Forward Argo CD UI
```
kubectl port-forward svc/argocd-server -n argocd 9090:443
```
Open in browser:
```
https://localhost:9090
```
🧪 Step 3: Port-Forward App Services (All Environments) -- in different wsl terminals
```
kubectl port-forward svc/myservice-dev -n dev 9080:5000
kubectl port-forward svc/myservice-test -n test 9081:5000
kubectl port-forward svc/myservice-prod -n prod 9082:5000
```
Test each:
```
curl http://localhost:9080
curl http://localhost:9081
curl http://localhost:9082
```
🛠️ After App Code Changes (e.g. Flask Fix)

🚀 Step 1: Rebuild Docker Image
```
docker build -t raman430/myservice:latest .
```
⬆️ Step 2: Push Image to Docker Hub
```
docker push raman430/myservice:latest
```
🔄 Step 3: Sync All Argo CD Apps
```
argocd app sync myservice-dev
argocd app sync myservice-test
argocd app sync myservice-prod
```
🔁 Step 4: (Optional) Force Restart to Pull New Image
```
kubectl rollout restart deployment myservice-dev -n dev
kubectl rollout restart deployment myservice-test -n test
kubectl rollout restart deployment myservice-prod -n prod
```
✅ Step 5: Re-verify All Services
```
curl http://localhost:9080
curl http://localhost:9081
curl http://localhost:9082
```

📘 Argo CD UI & Sync vs Health Explained

🎯 Argo CD Sync Status

Synced: YAML from Git matches the live Kubernetes object.

OutOfSync: The cluster differs from Git (manual edit, or drift).

🚥 Argo CD Health Status

Healthy: All resources are active and ready.

Progressing: One or more resources are still rolling out.

Degraded: A resource (like a pod) failed readiness or liveness.

Missing: A resource from the Git manifest was deleted from the cluster.

🧠 Key Insight

Sync = YAML matches clusterHealth = App is actually running and ready

🔧 How to Troubleshoot Failed Health
```
kubectl get pods -n <env>
kubectl describe pod <pod> -n <env>
kubectl logs <pod> -n <env>
```
Also: click on the resource tree in Argo CD UI to inspect issues like:

Failed probe

Image crash or exit

Mismatched port

🛑 Common Mistake

Relying only on "Synced" is misleading — always check the health status and pod logs for final confirmation.

