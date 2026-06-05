# 16 — Commands

Run in order. Read the output at each step.

---

## 1. Inspect available StorageClasses

```bash
kubectl get storageclass
kubectl describe storageclass standard
```

> What provisioner does the `standard` StorageClass use? Is it marked as default?

---

## 2. Create the namespace and apply the PVC

```bash
kubectl create namespace lab-16-storage
kubectl apply -f manifests/pvc.yaml
kubectl get pvc -n lab-16-storage
```

> What is the STATUS of the PVC? kind's local-path provisioner creates PVs lazily — the PVC may stay in `Pending` until a pod actually references it.

---

## 3. Apply the pod that uses the PVC

```bash
kubectl apply -f manifests/pod.yaml
kubectl get pod data-pod -n lab-16-storage
kubectl get pvc -n lab-16-storage
```

> Now what is the PVC status? Watch it change from Pending to Bound:

```bash
kubectl get pvc -n lab-16-storage -w
```

---

## 4. Inspect the PVC and its bound PV

```bash
kubectl describe pvc data-pvc -n lab-16-storage
```

> Look at: `Status`, `Volume` (the PV name), `Capacity`, `Access Modes`, `StorageClass`, `Events`.

```bash
kubectl get pv
```

> Find the PV that was auto-created. What is its reclaim policy?

---

## 5. Describe the PV

```bash
kubectl describe pv <pv-name>
```

> Look at: `Reclaim Policy`, `Status`, `Claim`, `Source`. Where on the node does the local-path provisioner actually store the data?

---

## 6. Confirm the pod wrote data

```bash
kubectl logs data-pod -n lab-16-storage
kubectl exec data-pod -n lab-16-storage -- cat /data/test.txt
```

---

## 7. Write more data to the PVC

```bash
kubectl exec data-pod -n lab-16-storage -- sh -c "echo 'second line' >> /data/test.txt && cat /data/test.txt"
```

---

## 8. Delete the pod and recreate it — data should survive

```bash
kubectl delete pod data-pod -n lab-16-storage
kubectl get pvc -n lab-16-storage
```

> Is the PVC still Bound after the pod is deleted?

```bash
kubectl apply -f manifests/pod.yaml
kubectl exec data-pod -n lab-16-storage -- cat /data/test.txt
```

> Is the data still there? This is the key difference from emptyDir and hostPath.

---

## 9. Apply the broken PVC

```bash
kubectl apply -f broken/pvc-wrong-storageclass.yaml
kubectl get pvc -n lab-16-storage
```

> What is the STATUS of `broken-pvc`? It should stay `Pending`.

---

## 10. Diagnose the broken PVC

```bash
kubectl describe pvc broken-pvc -n lab-16-storage
```

> Read the Events section. What does it say? What is the provisioner waiting for?

---

## 11. Try to create a pod that uses the broken PVC

```bash
kubectl run broken-pod \
  --image=busybox:1.36 \
  --namespace=lab-16-storage \
  --overrides='{"spec":{"volumes":[{"name":"v","persistentVolumeClaim":{"claimName":"broken-pvc"}}],"containers":[{"name":"broken-pod","image":"busybox:1.36","command":["sleep","3600"],"volumeMounts":[{"name":"v","mountPath":"/data"}]}]}}' \
  -- sleep 3600
kubectl get pod broken-pod -n lab-16-storage
```

> What status does the pod show? A pod that references a Pending PVC will itself stay Pending.

---

## 12. Fix the broken PVC

PVCs are immutable. Delete and recreate with the correct StorageClass:

```bash
kubectl delete pvc broken-pvc -n lab-16-storage
kubectl delete pod broken-pod -n lab-16-storage --ignore-not-found=true
```

Edit `broken/pvc-wrong-storageclass.yaml` — change `storageClassName: does-not-exist` to `storageClassName: standard`.

```bash
kubectl apply -f broken/pvc-wrong-storageclass.yaml
kubectl get pvc -n lab-16-storage
```

---

## 13. Observe PV reclaim behavior

Delete the original PVC and watch what happens to the PV:

```bash
kubectl delete pod data-pod -n lab-16-storage
kubectl delete pvc data-pvc -n lab-16-storage
kubectl get pv
```

> What status does the PV show after the PVC is deleted? What does the reclaim policy say will happen to the PV and its data?

---

## 14. Clean up

```bash
./cleanup.sh
```
