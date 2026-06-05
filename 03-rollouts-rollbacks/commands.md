# 03 — Commands

Run in order. Read the output at each step.

---

## 1. Create the namespace and apply the Deployment

```bash
kubectl create namespace lab-03-rollouts
kubectl apply -f manifests/deployment.yaml
kubectl rollout status deployment/nginx-deployment -n lab-03-rollouts
```

> What does `rollout status` tell you?

---

## 2. Check the current image version

```bash
kubectl get deployment nginx-deployment -n lab-03-rollouts -o wide
```

> What image is running?

---

## 3. Perform a successful rolling update

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26 -n lab-03-rollouts
kubectl rollout status deployment/nginx-deployment -n lab-03-rollouts
```

> Watch the output. What does Kubernetes do during the update?

---

## 4. Inspect rollout history

```bash
kubectl rollout history deployment/nginx-deployment -n lab-03-rollouts
```

> How many revisions are listed? What do they represent?

---

## 5. Get details of a specific revision

```bash
kubectl rollout history deployment/nginx-deployment --revision=1 -n lab-03-rollouts
kubectl rollout history deployment/nginx-deployment --revision=2 -n lab-03-rollouts
```

> What is different between revision 1 and revision 2?

---

## 6. Check the ReplicaSets

```bash
kubectl get replicasets -n lab-03-rollouts
```

> How many ReplicaSets exist now? What are their replica counts? Why does the old one still exist?

---

## 7. Push a broken image update

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:badversion -n lab-03-rollouts
```

```bash
kubectl get pods -n lab-03-rollouts
kubectl rollout status deployment/nginx-deployment -n lab-03-rollouts
```

> What is happening? Do all pods get replaced, or does the rollout stop? Why?

Press Ctrl+C to exit the rollout status watch after observing the stall.

---

## 8. Describe a failing pod

```bash
# Find a pod in ImagePullBackOff or ErrImagePull state
kubectl get pods -n lab-03-rollouts
kubectl describe pod <failing-pod-name> -n lab-03-rollouts
```

> What does the Events section say?

---

## 9. Roll back to the previous revision

```bash
kubectl rollout undo deployment/nginx-deployment -n lab-03-rollouts
kubectl rollout status deployment/nginx-deployment -n lab-03-rollouts
kubectl get pods -n lab-03-rollouts
```

> What image are the pods running now?

---

## 10. Verify the rollback

```bash
kubectl get deployment nginx-deployment -n lab-03-rollouts -o wide
kubectl rollout history deployment/nginx-deployment -n lab-03-rollouts
```

> How many revisions are listed after the rollback? What is the current revision's image?

---

## 11. Roll back to a specific revision

```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=1 -n lab-03-rollouts
kubectl get deployment nginx-deployment -n lab-03-rollouts -o wide
```

> What image is running now?

---

## 12. Clean up

```bash
./cleanup.sh
```
