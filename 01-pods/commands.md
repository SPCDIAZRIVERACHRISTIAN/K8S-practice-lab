# 01 — Commands

Run in order. Read the output at each step before continuing.

---

## 1. Create the namespace

```bash
kubectl create namespace lab-01-pods
```

---

## 2. Apply the pod

```bash
kubectl apply -f manifests/nginx-pod.yaml
```

---

## 3. Watch the pod start

```bash
kubectl get pods -n lab-01-pods
kubectl get pods -n lab-01-pods -w
```

> Press Ctrl+C to stop watching. What states did you see the pod move through?

---

## 4. Get pod details

```bash
kubectl get pod nginx-pod -n lab-01-pods -o wide
```

> What node is the pod running on? What is its IP address?

---

## 5. Describe the pod

```bash
kubectl describe pod nginx-pod -n lab-01-pods
```

> Scroll to the bottom and read the `Events` section. What happened during pod startup? Look at `Node`, `IP`, `Containers`, and `Conditions` too.

---

## 6. View the pod logs

```bash
kubectl logs nginx-pod -n lab-01-pods
```

> What is nginx printing to stdout? What does this log tell you?

---

## 7. Exec into the running pod

```bash
kubectl exec -it nginx-pod -n lab-01-pods -- /bin/bash
```

Inside the container, run:

```bash
hostname
env
curl localhost
exit
```

> You are inside the nginx container, not the node. What does `hostname` return?

---

## 8. Port-forward to access the pod from your local machine

```bash
kubectl port-forward pod/nginx-pod 8080:80 -n lab-01-pods
```

Open `http://localhost:8080` in your browser while the command runs. Press Ctrl+C when done.

> What did you see? Is this how you would expose nginx in production?

---

## 9. Apply the broken pod

```bash
kubectl apply -f broken/bad-image-pod.yaml
```

```bash
kubectl get pods -n lab-01-pods
kubectl describe pod nginx-bad-image -n lab-01-pods
```

> What status does the broken pod show? Look at the Events section. What error message do you see?

---

## 10. Fix the broken pod

Edit the broken pod manifest to use `nginx:stable` instead of `nginx:doesnotexist`, then re-apply:

```bash
kubectl apply -f broken/bad-image-pod.yaml
```

> Does an already-running pod with a bad image heal itself when you re-apply the manifest? Or do you need to delete and recreate?

---

## 11. Delete the working pod

```bash
kubectl delete pod nginx-pod -n lab-01-pods
```

```bash
kubectl get pods -n lab-01-pods
```

> Did the pod come back? Wait 30 seconds and check again. Write down what you see.

---

## 12. Clean up

```bash
./cleanup.sh
```
