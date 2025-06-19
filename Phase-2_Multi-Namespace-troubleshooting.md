🚀 Phase 2: Learnings & Summary – Multi-namespace Helm + ArgoCD on Minikube (WSL)
✅ Objective
Set up a local DevOps playground using:

Minikube (Kubernetes on local)

Helm charts for app deployment

Argo CD for GitOps-based sync

Deploy in dev, test, and prod namespaces

Automate everything with a cluster-startup.sh script

🧠 Key Learnings & Concepts
1. ✅ Helm with Multiple Namespaces
Each environment (dev, test, prod) is deployed as a separate Helm release

Chart values are defined in:

values-dev.yaml

values-test.yaml

values-prod.yaml

Each includes its target namespace:

yaml
Copy
Edit
namespace: dev
2. ✅ Namespace-Specific Ingress Hostnames
In ingress.yaml:

yaml
Copy
Edit
- host: {{ printf "%s.myservice.local" .Release.Namespace }}
3. ✅ Helm Conflicts Resolved
Error Encountered:

bash
Copy
Edit
INSTALLATION FAILED: Namespace "dev" exists and cannot be imported
Resolution:

Always clean old Helm releases before re-creating namespace:

bash
Copy
Edit
helm uninstall myservice-dev --namespace dev
kubectl delete namespace dev
⚙️ cluster-startup.sh Highlights
✅ Validates & Starts:
minikube

docker, helm, kubectl, git

Argo CD installation

Minikube tunnel (requires separate terminal in WSL)

Port-forwarding Argo CD to localhost:8080

✅ Deploys Helm Releases to:
dev.myservice.local

test.myservice.local

prod.myservice.local

Command used in script:

bash
Copy
Edit
helm upgrade --install myservice-dev ./charts/myservice \
  -f ./charts/myservice/values-dev.yaml \
  --namespace dev --create-namespace
🛠 Key Commands
Task	Command
Start Minikube	minikube start --driver=docker
View Pods	kubectl get pods -A
View Services	kubectl get svc -A
View Ingress	kubectl get ingress -A
Tunnel	minikube tunnel
Helm uninstall	helm uninstall myservice-dev -n dev
Delete namespace	kubectl delete ns dev
Install chart	helm install myservice-dev ./charts/myservice -f values-dev.yaml -n dev --create-namespace

🧩 Common Issues & Fixes
Issue	Resolution
Namespace exists error	Helm uninstall + namespace delete before reinstall
Ingress host conflicts	Use dynamic hostnames: {{ .Release.Namespace }}.myservice.local
Argo CD not reachable	Ensure port-forward is running
Minikube tunnel error	Check for existing tunnel with `ps aux

🔒 Best Practices
Use unique release name per namespace

Avoid hardcoded Ingress hostnames

Parameterize values via values-<env>.yaml

Avoid namespace pre-creation if Helm is creating it

For WSL users: manually edit Windows C:\Windows\System32\drivers\etc\hosts:

text
Copy
Edit
127.0.0.1 dev.myservice.local
127.0.0.1 test.myservice.local
127.0.0.1 prod.myservice.local
✅ Final URLs for Testing
Environment	URL
Dev	http://dev.myservice.local
Test	http://test.myservice.local
Prod	http://prod.myservice.local
ArgoCD	https://localhost:8080

===========
✅ Objective Recap

Deploy a Helm-based microservice app (Flask) into dev, test, and prod namespaces.

Use Argo CD to manage GitOps deployments.

Configure port-forwarding for local testing.

🧱 Initial Setup

Namespaces: dev, test, prod created by Helm chart.

Argo CD Applications created for each environment with respective values files.

containerPort initially misaligned with Flask default behavior.

❌ Issues Faced & Troubleshooting Journey

1. Pods in CrashLoopBackOff

Command Used:
```
kubectl get pods -n dev
kubectl logs <pod> -n dev
kubectl describe pod <pod> -n dev
```
Observation:

Flask started on 127.0.0.1:5000

Probes were trying to reach localhost:80

Root Cause:

Mismatch between app port and Kubernetes configuration

Flask was binding only to localhost

✅ Fixes:
```
Update server.py:

app.run(host="0.0.0.0", port=5000)

Update values.yaml, values-dev.yaml, etc.:

containerPort: 5000
service:
  port: 5000
```
Update Helm templates:
```
In deployment.yaml, ensure probes and ports use {{ .Values.containerPort }}

In service.yaml, ensure targetPort: {{ .Values.containerPort }}
```
2. Image Not Pulling Latest

Image was tagged latest, but new pushes weren't picked up.
```
Root Cause: Kubernetes cached the latest tag.
```
✅ Fixes:

Set in values.yaml:
```
image:
  pullPolicy: Always
```
Use kubectl rollout restart or argocd app sync to force redeploy:
```
argocd app sync myservice-dev
kubectl rollout restart deployment myservice-dev -n dev
```
3. Port Forwarding Failures

a. Port Already in Use

Error:

unable to listen on port 8080: address already in use

Fix:
```
lsof -i :8080
kill -9 <PID>
# or use a different port
kubectl port-forward svc/myservice-dev -n dev 8083:5000
```
b. Service Missing Target Port

Error:

error: Service myservice-test does not have a service port 5000

Fix: Update service.yaml Helm template:
```
ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.containerPort }}
```
🧪 Port Forwarding for All Envs
```
kubectl port-forward svc/myservice-dev -n dev 9080:5000
curl http://localhost:9080

kubectl port-forward svc/myservice-test -n test 9081:5000
curl http://localhost:9081

kubectl port-forward svc/myservice-prod -n prod 9082:5000
curl http://localhost:9082
```
For Argo CD UI:
```
kubectl port-forward svc/argocd-server -n argocd 9090:443
# Access: https://localhost:9090
```
📘 Learnings Summary

Topic

Learning

CrashLoopBackOff

Use kubectl logs + describe to catch port/probe/image issues

Flask Networking

Always bind to 0.0.0.0 for containerized apps

Helm Values

Ensure containerPort and service.port are consistent

Argo CD Sync

Manual argocd app sync is essential for image tag updates

Port Forwarding

Useful for debugging internal services locally

Service Template

targetPort should reference .Values.containerPort

=====================================