✅ Kubernetes Secure Lab – Troubleshooting Recap & Lessons Learned

This section documents all issues encountered during the microservice deployment via Helm + ArgoCD + Ingress setup, along with step-by-step verification, solutions, and final working state.

⚠️ Issues Encountered & How We Fixed Them

1. Invalid Image Name in Pod

Symptom: InvalidImageName in pod status.

Cause: values.yaml had image: raman430/myservice:latest:latest.

Fix:

Corrected to tag: latest.

Rebuilt and pushed Docker image:

docker build -t raman430/myservice:latest ./app
docker push raman430/myservice:latest

2. 503 Service Temporarily Unavailable from Ingress

Symptom: curl http://myservice.local returns a 503 error.

Cause: Ingress couldn’t reach backend service due to port mismatch.

Fix:

Verified pod and service:

kubectl get pods
kubectl get svc myservice -o yaml

Corrected targetPort to match the named port http.

Ensured container port in deployment uses:

ports:
  - name: http
    containerPort: 5000

Updated Ingress backend to use service port 80.

3. DNS_PROBE_POSSIBLE in Browser

Symptom: myservice.local not resolving in Chrome.

Cause: Chrome in Windows not honoring WSL2 /etc/hosts entry.

Fix:

Verified /etc/hosts:

echo "127.0.0.1 myservice.local" | sudo tee -a /etc/hosts

Used curl inside WSL:

curl http://myservice.local

For browser access, used:

minikube service myservice --url

4. YAML Indentation Errors in values.yaml

Error: "All mapping items must start at the same column."

Cause: Used annotations: {} followed by indented fields.

Fix: Replaced with:

annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /

5. Helm Chart Drift vs ArgoCD Sync

Issue: Changes deployed manually not synced in ArgoCD.

Fix: Committed all working files:

git add charts/myservice
git commit -m "Fix port mapping and ingress rewrite"
git push origin main

✅ Final Configuration Changes

values.yaml

image:
  repository: raman430/myservice
  tag: latest
  pullPolicy: IfNotPresent

containerPort: 5000

service:
  type: ClusterIP
  port: 80
  targetPort: 5000

ingress:
  enabled: true
  hostname: myservice.local
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  hosts:
    - host: myservice.local
      paths:
        - path: /
          pathType: Prefix

deployment.yaml

ports:
  - name: http
    containerPort: {{ .Values.containerPort }}
    protocol: TCP

service.yaml

ports:
  - name: http
    port: {{ .Values.service.port }}
    targetPort: http
    protocol: TCP

ingress.yaml

rules:
  - host: {{ .Values.ingress.hostname }}
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: {{ include "myservice.fullname" . }}
              port:
                number: {{ .Values.service.port }}

🧪 Key Commands Used

# Build and Push Docker Image
cd app
docker build -t raman430/myservice:latest .
docker push raman430/myservice:latest

# Upgrade Helm Chart
helm upgrade --install myservice ./charts/myservice

# Check Kubernetes Resources
kubectl get pods
kubectl get svc
kubectl describe ingress myservice-ingress

# Run Minikube Tunnel
minikube tunnel

# Test DNS Mapping
curl http://myservice.local

# Open Service via Minikube (Browser-friendly)
minikube service myservice --url

🎯 Lessons Learned

Always align targetPort in service with either a named port or actual container port

Define named ports in container (http) and use that in service

YAML indentation matters — avoid inline {} if nesting child keys

Browsers don’t always respect /etc/hosts in WSL2 — use curl or NodePort for testing

ArgoCD tracks Git — local Helm changes must be pushed to persist

Ingress needs rewrite-target: / annotation and proper port mapping

✅ This doc serves as a go-to reference for Helm-based microservice debugging with Ingress and GitOps.