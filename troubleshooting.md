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


| **Issue**                         | **Verification Command / Method**                             | **Fix / Change Made**                                                       | **Lesson Learned**                                                 |
| --------------------------------- | ------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Missing Dockerfile                | `docker build -t ...` failed with `no such file or directory` | Created valid `Dockerfile` in correct directory                             | Always verify file paths before build                              |
| Image tag error (`latest:latest`) | `kubectl get deployment -o yaml \| grep image`                | Fixed `values.yaml` to use valid `image.repository:tag` format              | Avoid accidental double-tagging (`:latest:latest`)                 |
| CrashLoopBackOff                  | `kubectl get pods` and `kubectl logs <pod>`                   | Rebuilt Docker image with fixed `CMD` in Dockerfile                         | Validate app startup locally before pushing                        |
| Ingress 503 Error                 | `curl http://myservice.local`, `kubectl get ingress`          | Fixed `targetPort` in `Ingress` to match container port (`5000`)            | Ingress must forward to correct backend port                       |
| Wrong `host` in Ingress           | `curl` result and inspecting `values.yaml`                    | Changed `hosts[].host` to `myservice.local` in `values.yaml`                | Ingress host must match entry in `/etc/hosts`                      |
| `/etc/hosts` entry missing        | `cat /etc/hosts`                                              | Added `127.0.0.1 myservice.local`                                           | Required for local DNS-style routing                               |
| Service `targetPort` mismatch     | `kubectl get svc myservice -o yaml`                           | Ensured `targetPort: http` resolved to container’s named port `http` (5000) | Align `port.name` and `targetPort` naming in Service and container |
| Unreachable app                   | `curl`, pod logs, Service and Ingress checks                  | Fixed container `CMD`, ports, and Ingress                                   | Each layer (Pod → Service → Ingress) must be verified step-by-step |
| No feedback from `curl`           | `curl http://myservice.local` returned 503                    | Final success: app responded with `Hello from K8s with Helm & GitOps!`      | End-to-end check validates all config layers                       |
