# 17 — Commands

Run in order. Read the output at each step. Some steps require waiting for pods to start or terminate.

---

## 1. Create the namespace and apply manifests

```bash
kubectl create namespace lab-17-statefulsets
kubectl apply -f manifests/headless-service.yaml
kubectl apply -f manifests/statefulset.yaml
```

---

## 2. Watch pods start in order

```bash
kubectl get pods -n lab-17-statefulsets -w
```

> Press Ctrl+C after all three pods are Running. Did web-0 become Running before web-1 started? Did web-1 before web-2?

---

## 3. List the pods and their names

```bash
kubectl get pods -n lab-17-statefulsets
```

> What are the pod names? Notice the ordinal suffix.

---

## 4. List the PVCs that were auto-created

```bash
kubectl get pvc -n lab-17-statefulsets
```

> How many PVCs were created? What are their names? How do they relate to the pod names?

---

## 5. Write a unique file to each pod's PVC

```bash
kubectl exec web-0 -n lab-17-statefulsets -- sh -c "echo 'I am web-0' > /data/id.txt"
kubectl exec web-1 -n lab-17-statefulsets -- sh -c "echo 'I am web-1' > /data/id.txt"
kubectl exec web-2 -n lab-17-statefulsets -- sh -c "echo 'I am web-2' > /data/id.txt"
```

Verify:

```bash
kubectl exec web-0 -n lab-17-statefulsets -- cat /data/id.txt
kubectl exec web-1 -n lab-17-statefulsets -- cat /data/id.txt
kubectl exec web-2 -n lab-17-statefulsets -- cat /data/id.txt
```

> Each pod has its own isolated PVC with its own data.

---

## 6. Test stable DNS via the headless Service

```bash
kubectl run dns-test --image=busybox:1.36 --rm -it --restart=Never \
  -n lab-17-statefulsets -- sh
```

Inside the shell:

```sh
nslookup web-0.web.lab-17-statefulsets.svc.cluster.local
nslookup web-1.web.lab-17-statefulsets.svc.cluster.local
nslookup web-2.web.lab-17-statefulsets.svc.cluster.local
nslookup web.lab-17-statefulsets.svc.cluster.local
exit
```

> The last query (the headless Service name) should return ALL pod IPs. The per-pod queries return specific IPs. How does this differ from a regular ClusterIP Service?

---

## 7. Delete web-1 and observe pod identity recovery

```bash
kubectl delete pod web-1 -n lab-17-statefulsets
kubectl get pods -n lab-17-statefulsets -w
```

> Press Ctrl+C after web-1 is Running again. What is the new pod's name? Is it still `web-1`?

---

## 8. Confirm the data survived

```bash
kubectl exec web-1 -n lab-17-statefulsets -- cat /data/id.txt
```

> Is the data you wrote earlier still there? The pod identity and PVC binding are preserved.

---

## 9. Scale up to 5 replicas

```bash
kubectl scale statefulset web --replicas=5 -n lab-17-statefulsets
kubectl get pods -n lab-17-statefulsets -w
```

> In what order do web-3 and web-4 appear? Does web-3 become Ready before web-4 starts?

---

## 10. List PVCs after scale-up

```bash
kubectl get pvc -n lab-17-statefulsets
```

> Are there now 5 PVCs?

---

## 11. Scale down to 2 replicas

```bash
kubectl scale statefulset web --replicas=2 -n lab-17-statefulsets
kubectl get pods -n lab-17-statefulsets -w
```

> Press Ctrl+C after scale-down. In what order were pods removed? Which pod was deleted first — web-4 or web-2?

---

## 12. Check what happened to the PVCs after scale-down

```bash
kubectl get pvc -n lab-17-statefulsets
```

> How many PVCs remain? Are the PVCs for web-2, web-3, web-4 still there even though the pods are gone?

---

## 13. Scale back up and confirm data is still on the PVCs

```bash
kubectl scale statefulset web --replicas=5 -n lab-17-statefulsets
kubectl get pods -n lab-17-statefulsets
```

Wait for pods to start, then check whether the old data is still on web-2:

```bash
kubectl exec web-2 -n lab-17-statefulsets -- cat /data/id.txt
```

> Is the data from step 5 still there? The PVC retained the data during the scale-down window.

---

## 14. Clean up

```bash
./cleanup.sh
```
