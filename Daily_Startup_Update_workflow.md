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
🧪 Step 3: Port-Forward App Services (All Environments)
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