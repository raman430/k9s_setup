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
