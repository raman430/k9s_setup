🧭 Kubernetes Lab: Minikube + GitOps + Helm + HPA

✅ Project Directory: ~/projects/k9s_setup

🔧 Cluster Lifecycle Commands

📛 Stop Minikube Cluster

minikube stop

🚀 Start Minikube Cluster (with Docker driver)

minikube start --driver=docker

↻ Restart Cluster (Stop + Start)

minikube stop && minikube start --driver=docker

🔍 Check Cluster Status

minikube status

🌐 Ingress Requirements (Post Restart)

🧵 Restart Tunnel for Ingress to Work

minikube tunnel

Run this in a separate terminal if using myservice.local

💃 Git Commands Recap (SSH-based GitHub Repo)

🚪 Verify SSH Connection to GitHub

ssh -T git@github.com

↻ Update Remote Repo (if not done)

git remote set-url origin git@github.com:raman430/k9s_setup.git

📄 Push Code to GitHub

git add .
git commit -m "Your message"
git push --set-upstream origin main

⛩️ Argo CD GitOps Sync

✍️ Apply ArgoCD Application YAML

kubectl apply -f gitops/myservice-app.yaml

📋 Check ArgoCD App Status

kubectl get applications -n argocd
kubectl describe application myservice -n argocd

📈 HPA (Autoscaling) Commands

✅ Enable Metrics Server

minikube addons enable metrics-server

📊 View HPA Status

kubectl get hpa
kubectl describe hpa myservice

🔥 Simulate Load
