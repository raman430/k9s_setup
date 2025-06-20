# Basic shortcuts
```
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgs='kubectl get svc'
alias kga='kubectl get all'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kctx='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'
```
# Describe / Logs / Exec
```
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
```
# Apply / Delete
```
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
```

# Port-forwarding
```
alias kpf='kubectl port-forward'
```
# YAML output
```
alias ky='kubectl get -o yaml'
```
### ✅ Example Usage Table for `kubectl` Aliases

| Task                     | Command                                 |
|--------------------------|------------------------------------------|
| Apply YAML               | `kaf myfile.yaml`                        |
| Delete YAML              | `kdf myfile.yaml`                        |
| Get pods in all NS       | `kgpa`                                   |
| Get services             | `kgs`                                    |
| Describe a pod           | `kdp mypod -n dev`                       |
| View pod logs            | `kl mypod -n dev`                        |
| Exec into a container    | `ke mypod -n dev -- sh`                  |
| Get current context      | `kctx`                                   |
| Change current namespace | `kns dev`                                |
| Port-forward a service   | `kpf svc/myservice-dev 9080:5000 -n dev` |
🧠 Bonus: Add Tab Completion (Optional but Powerful)
After installing kubectl completion:
```
bash
Copy
Edit
source <(kubectl completion bash)  # or zsh
```
🛠️ Apply Aliases Immediately
After adding to .bashrc or .zshrc:
```
bash
Copy
Edit
source ~/.bashrc    # or ~/.zshrc
```