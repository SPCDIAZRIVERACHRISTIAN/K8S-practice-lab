# 02 — Commands

Run in order. Read the output at each step.

---

## 1. Create the namespace and apply the Deployment

```bash
kubectl create namespace lab-02-deployments
kubectl apply -f manifests/deployment.yaml
```

---

## 2. Watch the pods appear

```bash
kubectl get pods -n lab-02-deployments -w
```

> Press Ctrl+C after all 3 pods reach Running. How long did it take?

---

## 3. Inspect the Deployment

```bash
kubectl get deployment -n lab-02-deployments
kubectl describe deployment nginx-deployment -n lab-02-deployments
```

> Look at: `Replicas`, `Selector`, `StrategyType`, `Events`. What does `3/3` under Replicas mean?

---

## 4. Inspect the ReplicaSet

```bash
kubectl get replicaset -n lab-02-deployments
kubectl describe replicaset -n lab-02-deployments
```

> What is the ReplicaSet's name? How does its selector relate to the pod labels?

---

## 5. Inspect the pods and their labels

```bash
kubectl get pods -n lab-02-deployments --show-labels
```

> What labels do the pods have? Where do those labels come from in the manifest?

---

## 6. Delete one pod and watch it come back

```bash
# Copy one of the pod names from kubectl get pods
kubectl delete pod <pod-name> -n lab-02-deployments
kubectl get pods -n lab-02-deployments -w
```

> Press Ctrl+C once a new pod reaches Running. What happened? How fast was the replacement?

---

## 7. Scale up to 5 replicas

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n lab-02-deployments
kubectl get pods -n lab-02-deployments
```

> How many pods are there now? Did the ReplicaSet name change?

---

## 8. Scale down to 2 replicas

```bash
kubectl scale deployment nginx-deployment --replicas=2 -n lab-02-deployments
kubectl get pods -n lab-02-deployments
```

> Which pods were kept? Which were deleted? Is the order predictable?

---

## 9. Apply the broken selector

```bash
kubectl apply -f broken/deployment-bad-selector.yaml
```

> What error do you get? Read it carefully. Write it down in notes.md.

---

## 10. Verify the broken deployment was not created

```bash
kubectl get deployments -n lab-02-deployments
```

> Is `nginx-broken-selector` listed?

---

## 11. Clean up

```bash
./cleanup.sh
```
