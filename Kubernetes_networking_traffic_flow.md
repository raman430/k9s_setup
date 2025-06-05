🌐 Kubernetes Networking & Traffic Flow – Explained Simply

This document breaks down how traffic flows from your browser to your Flask app running in Kubernetes via Minikube, using simple language, analogies, and a layered walkthrough.

🧭 Scenario: You open your browser and type:

http://myservice.local

You're trying to reach your app deployed in Kubernetes using Helm and exposed via Ingress.

🔗 Step-by-Step Traffic Flow

1. Browser Request

You request http://myservice.local

Your computer asks:

"Where is myservice.local?"

2. /etc/hosts Lookup

Your /etc/hosts file responds:

127.0.0.1 myservice.local

This is a manual shortcut that says:

"Hey system, when someone says 'myservice.local', just loop it back to me (localhost)."

✅ Why? Because you’re not using external DNS — you're faking it locally.

3. Minikube Tunnel

Command you ran:

minikube tunnel

Think of this as:

"Open a gate in the city wall (Minikube) so the world (your machine) can get in."

🧠 Without this tunnel, the Ingress route wouldn't be reachable from outside.

4. Ingress Controller (NGINX)

NGINX is the traffic cop or receptionist at the city gate.

It receives the request for myservice.local.

Based on your ingress.yaml, it routes the request to the correct internal Service.

🧠 Analogy: NGINX says:

"This visitor is looking for path / on host myservice.local. That goes to Service myservice."

5. Kubernetes Service

The Service is the internal router.

It listens on port 80 and forwards traffic to the correct Pod on port 5000.

✅ This is the mapping from service-level port → container port.

🧠 Analogy: Service says:

"Take this guest to room 5000 — that's where the Flask app is listening."

6. Pod (Flask App)

Inside the Pod, Flask is running with:

app.run(host="0.0.0.0", port=5000)

It receives the request and responds with:

"Hello from K8s with Helm & GitOps!"

Response travels back the same path:
Pod → Service → Ingress → Tunnel → Browser

✅ Boom — response rendered in your browser or via curl.

🧠 Recap – Layered Flow

Browser (you)
   ↓
/etc/hosts (maps to 127.0.0.1)
   ↓
Minikube Tunnel (opens entry to cluster)
   ↓
Ingress Controller (routes based on host/path)
   ↓
Kubernetes Service (maps request to target pod)
   ↓
Pod (Flask app responds)
   ↓
Back to you 🎉

🔐 Bonus: Key Networking Components

| **Step** | **Component**                 | **What It Does**                                                         | **Example / Key Config**                                                      |
| -------- | ----------------------------- | ------------------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| 1        | `curl http://myservice.local` | Sends request from browser/terminal to your local machine                | Requires `myservice.local` in `/etc/hosts` pointing to `127.0.0.1`            |
| 2        | Minikube Tunnel (optional)    | Bridges external access to internal ClusterIP if needed for LoadBalancer | `minikube tunnel` (not required for Ingress setup in this case)               |
| 3        | Ingress Controller (nginx)    | Listens on port 80, matches host/path, routes traffic to Service         | Ingress rule: `host: myservice.local`, `path: /`, `backend: servicePort 5000` |
| 4        | Kubernetes Ingress Object     | Defines routing rules used by the controller                             | `ingress.yaml` uses `.Values.ingress.hostname` and forwards to `port 5000`    |
| 5        | Kubernetes Service            | Abstracts and load-balances traffic to matching Pods                     | `type: ClusterIP`, `targetPort: http` (which maps to `5000`)                  |
| 6        | Deployment / Pod              | Pod container receives traffic on its containerPort (5000)               | Flask app listens on `0.0.0.0:5000` inside `server.py`                        |
