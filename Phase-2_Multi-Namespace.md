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

```
 Helm Commands to Deploy per Namespace
```
# Dev
helm upgrade --install myservice-dev ./charts/myservice -f ./charts/myservice/values-dev.yaml --namespace dev --create-namespace

# Test
helm upgrade --install myservice-test ./charts/myservice -f ./charts/myservice/values-test.yaml --namespace test --create-namespace

# Prod
helm upgrade --install myservice-prod ./charts/myservice -f ./charts/myservice/values-prod.yaml --namespace prod --create-namespace

```