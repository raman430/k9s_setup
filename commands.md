🧭 STEP-BY-STEP PROGRESS EXPLAINED SIMPLY

This section explains what you've done so far — in simple, layman's language — ideal for documentation and future reference.

✅ STEP 1: Set up Ubuntu inside Windows

You used WSL2 to run Ubuntu Linux on your Windows PC. This gives you a Linux-like development environment just like the cloud.

✅ STEP 2: Installed Core Tools (Toolbox Setup)

You installed the core tools required to develop, deploy, and manage apps:

git for version control

docker for building container images

kubectl for managing Kubernetes

minikube to simulate a Kubernetes cluster locally

helm to manage Kubernetes applications

vscode to edit code easily

✅ STEP 3: Created a Microservice

You built a basic Python web server that prints a simple message. This microservice will be packaged and deployed to Kubernetes.

✅ STEP 4: Dockerized the Application

You wrote a Dockerfile to containerize your Python app. You then:

Built the Docker image

Pushed it to DockerHub so Kubernetes can pull it

✅ STEP 5: Helm Chart Setup

You created a Helm chart, which is like a blueprint or template to define how your app runs in Kubernetes (including deployment, service, etc).

✅ STEP 6: GitHub + GitOps via Argo CD

You:

Created a GitHub repo and pushed your project

Installed and configured Argo CD

Created an Application definition in YAML to tell Argo CD to watch your GitHub repo and sync changes

✅ STEP 7: Ingress Setup

You set up Ingress NGINX so your service could be accessed through a custom domain name (myservice.local).
You edited /etc/hosts to make this work locally.

✅ STEP 8: Autoscaling with HPA

You added an HPA (Horizontal Pod Autoscaler) definition into your Helm chart. When CPU usage goes up, Kubernetes will scale your pods automatically.

🧱 Cluster Lifecycle Commands

⏹️ Stop Minikube Cluster

minikube stop

🚀 Start Minikube Cluster (with Docker driver)

minikube start --driver=docker

🔁 Restart Cluster (Stop + Start)

minikube stop && minikube start --driver=docker

🔎 Check Cluster Status

minikube status

🌐 Ingress Requirements (Post Restart)

🪄 Restart Tunnel for Ingress to Work

minikube tunnel

Run this in a separate terminal if using myservice.local

💃 Git Commands Recap (SSH-based GitHub Repo)

🔐 Verify SSH Connection to GitHub

ssh -T git@github.com

🔃 Update Remote Repo (if not done)

git remote set-url origin git@github.com:raman430/k9s_setup.git

📤 Push Code to GitHub

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