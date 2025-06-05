✅ Kubernetes Secure Lab – Troubleshooting Recap & Lessons Learned

This section documents all issues encountered during the microservice deployment via Helm + ArgoCD + Ingress setup, along with step-by-step verification, solutions, and final working state.

⚠️ ISSUES ENCOUNTERED & HOW WE FIXED THEM

1. ❌ InvalidImageName in Pod

Cause: values.yaml had image: raman430/myservice:latest:latest

Fix:

Corrected to tag: latest

Rebuilt and pushed Docker image:

docker build -t raman430/myservice:latest ./app
docker push raman430/myservice:latest

2. ❌ 503 Service Temporarily Unavailable from Ingress

Cause: Ingress couldn't reach backend service

Verifications:

Pod running: kubectl get pods

Service status:

kubectl get svc myservice -o yaml

Ingress routing:

kubectl describe ingress myservice-ingress

Fix:

Corrected targetPort: http in service.yaml

Ensured Deployment has:

ports:
  - name: http
    containerPort: 5000

Corrected ingress.yaml:

port:
  number: 80

3. ❌ DNS_PROBE_POSSIBLE in Browser

Cause: Browser couldn’t resolve myservice.local

Fix:

Added to /etc/hosts:

echo "127.0.0.1 myservice.local" | sudo tee -a /etc/hosts

Access via CLI (WSL2):

curl http://myservice.local

For browser, used NodePort or minikube service:

minikube service myservice --url

4. ❌ YAML Indentation Errors in values.yaml

Error:

All mapping items must start at the same column

Fix: Removed annotations: {} and replaced with correct indentation:

annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /

5. ❌ Helm Chart Drift vs ArgoCD

Fix: Committed working changes after local testing:

git add charts/myservice
git commit -m "Fix port mapping and ingress rewrite"
git push origin main

✅ FINAL CONFIGURATION CHANGES

✅ values.yaml

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

✅ deployment.yaml

ports:
  - name: http
    containerPort: {{ .Values.containerPort }}
    protocol: TCP

✅ service.yaml

ports:
  - name: http
    port: {{ .Values.service.port }}
    targetPort: http
    protocol: TCP

✅ ingress.yaml

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

✅ KEY COMMANDS USED

# Docker Build & Push
cd app
docker build -t raman430/myservice:latest .
docker push raman430/myservice:latest

# Helm Install/Upgrade
helm upgrade --install myservice ./charts/myservice

# Check Pod & Service
kubectl get pods
kubectl get svc
kubectl describe ingress myservice-ingress

# Local DNS mapping
sudo nano /etc/hosts
# Add: 127.0.0.1 myservice.local

# Minikube Tunnel
minikube tunnel

# Test Endpoint
curl http://myservice.local

🎯 LESSONS LEARNED

Always match targetPort in service to either a valid number or a named port in deployment

containerPort goes into deployment, not service block

Browsers in Windows may not respect /etc/hosts in WSL2 — test with curl

YAML indentation is critical — avoid using {} with multi-line mappings

Commit after verified success to avoid ArgoCD drift

Ingress paths need rewrite annotation + correct backend service/port mapping

