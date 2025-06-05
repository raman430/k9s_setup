STEP-BY-STEP PROGRESS EXPLAINED SIMPLY

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

🔵 Cluster Start/Stop Commands

minikube stop                      # Stop the cluster
minikube start --driver=docker    # Start the cluster
minikube tunnel                    # Enable access for Ingress

############################################################
🔧 Daily Startup Checklist with Fixes

1. ✅ Minikube Status

minikube status

Expected: All components should be Running.
If not:

minikube start --driver=docker

2. ✅ Start Tunnel (for Ingress)

minikube tunnel

Run in a separate terminal window.

3. ✅ Node Status

kubectl get nodes -o wide

Expected: Ready

If not:

minikube stop && minikube start --driver=docker

4. ✅ Argo CD Core Pods

kubectl get pods -n argocd

Expected: All Running

If not:

kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl rollout restart deployment argocd-server -n argocd

5. ✅ Argo CD Application Sync Status

kubectl get applications -n argocd
kubectl describe application myservice -n argocd

Expected: Synced and Healthy

If not:

kubectl apply -f gitops/myservice-app.yaml

6. ✅ Microservice Pod

kubectl get pods

Expected: Running

If not:

kubectl describe pod <pod-name>
kubectl logs <pod-name>

7. ✅ Ingress Controller Pod

kubectl get pods -n ingress-nginx

Expected: Controller should be Running

If not:

helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace

8. ✅ Ingress Rule & Hosts Mapping

kubectl get ingress
cat /etc/hosts | grep myservice.local

If not present:

echo "127.0.0.1 myservice.local" | sudo tee -a /etc/hosts

9. ✅ Curl Test

curl http://myservice.local

Expected: Hello from K8s with Helm & GitOps!

If fails:

Check pod status

Check ingress

Ensure tunnel is active

10. ✅ HPA (Autoscaler)

kubectl get hpa
kubectl describe hpa myservice

If missing:
minikube addons enable metrics-server
