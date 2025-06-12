📦 Phase 2: Multi-Namespace Setup & Real-World Troubleshooting Scenarios
🎯 Objective
In Phase 2, we are transitioning our Minikube-based Helm/Kubernetes lab setup to a more realistic, production-aligned architecture using multiple namespaces. The goal is to simulate real-world cluster management across dev, test, and prod environments and test practical DevOps and Kubernetes troubleshooting scenarios in a secure, repeatable, and best-practice-driven manner.

🛠️ Key Enhancements
```
✅ Introduced three namespaces: dev, test, prod

✅ Each namespace runs a dedicated Pod of the same application (myservice)

✅ All resources are isolated by namespace to simulate real deployment environments

✅ Helm values templating enhanced to support dynamic namespaces

✅ Ingress updated to correctly route requests per environment (if extended)

✅ Maintained original Helm structure while enabling environment-specific overrides via values-dev.yaml, values-test.yaml, values-prod.yaml
```

Updated Folder Structure
```
k9s_setup/
├── charts/
│   └── myservice/
│       ├── charts/
│       ├── templates/
│       │   ├── _helpers.tpl
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── ingress.yaml
│       │   └── namespace.yaml     <-- ✅ New
│       ├── values.yaml            <-- ✅ Updated (for default)
│       ├── values-dev.yaml        <-- ✅ New
│       ├── values-test.yaml       <-- ✅ New
│       └── values-prod.yaml       <-- ✅ New
├── README.md                      <-- ✅ Updated


# 🚀 Phase 2: Multi-Namespace GitOps with Helm & Argo CD

This phase sets up a GitOps-ready Kubernetes lab on Minikube with support for `dev`, `test`, and `prod` environments using **Helm** and **Argo CD**.

---

## 📦 Helm Setup Across Namespaces

Helm chart `charts/myservice` is deployed dynamically into different namespaces using three values files:
- `values-dev.yaml`
- `values-test.yaml`
- `values-prod.yaml`

Each values file defines:
```yaml
namespace: dev  # or test/prod
```

Helm installs are executed using:
```bash
helm upgrade --install myservice-dev ./charts/myservice -f ./charts/myservice/values-dev.yaml
helm upgrade --install myservice-test ./charts/myservice -f ./charts/myservice/values-test.yaml
helm upgrade --install myservice-prod ./charts/myservice -f ./charts/myservice/values-prod.yaml
```

Namespace creation is handled dynamically via this Helm template:
```yaml
# templates/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.namespace }}
  labels:
    environment: {{ .Values.namespace }}
```

---

## 🚀 Argo CD GitOps Integration

Argo CD is installed once and manages apps across all namespaces.

### 📥 Installation Commands

```bash
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 🔍 Validate Installation

```bash
kubectl get pods -n argocd
```

### 🌐 Access Argo CD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit http://localhost:8080
```

Get default password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

---

## 📄 Argo CD Application Definitions

Example: `gitops/myservice-dev-app.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myservice-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<your-username>/k9s_setup.git
    targetRevision: HEAD
    path: charts/myservice
    helm:
      valueFiles:
        - values-dev.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Repeat for `test` and `prod` with appropriate values files and namespaces.

Apply all:
```bash
kubectl apply -n argocd -f gitops/myservice-dev-app.yaml
kubectl apply -n argocd -f gitops/myservice-test-app.yaml
kubectl apply -n argocd -f gitops/myservice-prod-app.yaml
```

---

## 🧠 Key Learnings

- Helm templates support multi-namespace deployments via `.Values.namespace`
- Argo CD CRDs must be installed for GitOps to work
- Argo CD watches Git repo and reconciles deployments continuously
- Access to all namespaces must be granted to Argo CD controller

---

✅ All Argo CD + multi-namespace work is part of this **Phase 2 GitOps foundation**.
