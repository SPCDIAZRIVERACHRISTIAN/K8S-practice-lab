# 10 — Commands

Run in order. Read the output at each step.

---

## 1. Apply all manifests

```bash
kubectl apply -f manifests/namespaces.yaml
kubectl apply -f manifests/team-a.yaml
kubectl apply -f manifests/team-b.yaml
```

---

## 2. List namespaces

```bash
kubectl get namespaces
kubectl get namespaces --show-labels
```

> How many namespaces exist in the cluster? Which ones are system namespaces vs lab namespaces?

---

## 3. List Deployments in each namespace individually

```bash
kubectl get deployments -n lab-10-team-a
kubectl get deployments -n lab-10-team-b
```

> Both namespaces have a Deployment named `frontend`. Can you tell them apart from here?

---

## 4. List ALL Deployments across all namespaces

```bash
kubectl get deployments -A
```

> Which column tells you which namespace each Deployment belongs to?

---

## 5. List ALL pods across all namespaces

```bash
kubectl get pods -A
```

> How many pods are there? Include both lab namespaces and system namespaces.

---

## 6. Reproduce "resource not found" with wrong namespace

```bash
kubectl get deployment frontend -n lab-10-team-b
kubectl get deployment backend -n lab-10-team-b
```

> What error does the second command produce? The `backend` Deployment exists — just not in `lab-10-team-b`.

---

## 7. Filter pods by label across all namespaces

```bash
kubectl get pods -A -l tier=frontend
kubectl get pods -A -l tier=backend
kubectl get pods -A -l env=staging
```

> Labels let you find resources regardless of which namespace they live in. How many pods appear for each query?

---

## 8. Use multiple label selectors

```bash
kubectl get pods -A -l team=a,tier=frontend
kubectl get pods -A -l team=b,tier=backend
```

> The second query should return nothing. Why?

---

## 9. List pods with labels shown

```bash
kubectl get pods -n lab-10-team-a --show-labels
kubectl get pods -n lab-10-team-b --show-labels
```

> Compare the labels on the two `frontend` deployments' pods.

---

## 10. Inspect annotations

```bash
kubectl describe deployment frontend -n lab-10-team-a
kubectl describe deployment frontend -n lab-10-team-b
```

> Find the `Annotations` section. What annotations do they have? How are annotations different from labels?

---

## 11. Add a label to a running pod imperatively

```bash
# Get a pod name from lab-10-team-a
kubectl get pods -n lab-10-team-a

# Add a label to it
kubectl label pod <pod-name> -n lab-10-team-a hotfix=true

# Verify
kubectl get pod <pod-name> -n lab-10-team-a --show-labels
```

> The pod now has an extra label the ReplicaSet did not give it. What happens if you now filter by `hotfix=true`?

---

## 12. Detach a pod from its ReplicaSet by changing its labels

```bash
# Remove the 'app' label that the ReplicaSet selector uses
kubectl label pod <pod-name> -n lab-10-team-a app-

# Immediately check pod count
kubectl get pods -n lab-10-team-a
```

> What happened? How many pods are there now? Which one lost its app label?

---

## 13. Restore: re-label the orphaned pod

```bash
kubectl label pod <pod-name> -n lab-10-team-a app=frontend
kubectl get pods -n lab-10-team-a
```

> Now the ReplicaSet sees too many pods. What does it do?

---

## 14. Add an annotation imperatively

```bash
kubectl annotate deployment backend -n lab-10-team-a runbook="https://wiki.example.com/backend"
kubectl describe deployment backend -n lab-10-team-a | grep -A5 Annotations
```

---

## 15. Clean up

```bash
./cleanup.sh
```
