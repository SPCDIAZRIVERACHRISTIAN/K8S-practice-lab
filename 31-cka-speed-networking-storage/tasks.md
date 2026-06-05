# Lab 31 — CKA Speed Networking & Storage: Tasks

**Total target time:** 60 minutes  
**Namespace:** `speed-31`  
**Setup:** Apply `setup/namespace.yaml` and `setup/backend-deployment.yaml` before starting.

Start a timer when you begin Task 1. Record your actual time for each task in `notes.md`.

---

## Task 1 — Create a ClusterIP service with port mapping [target: 3 min]

**Context:** The `api` deployment in `speed-31` serves traffic on port 80. Clients connect on port 8080.

**Task:** Create a ClusterIP service named `api-svc` in namespace `speed-31` that routes port 8080 to targetPort 80, selecting pods with label `app=api`.

**Verify:**
```
kubectl get svc api-svc -n speed-31
kubectl get endpoints api-svc -n speed-31
```
Endpoints should be populated (not `<none>`).

---

## Task 2 — DNS resolution from inside a temporary pod [target: 3 min]

**Context:** You need to confirm the service is discoverable via DNS.

**Task:** Start a temporary busybox:stable pod using `kubectl run` with `--rm -it`. From inside the pod, resolve the DNS name `api-svc.speed-31.svc.cluster.local`.

**Verify:** The `nslookup` command returns a valid IP address matching the ClusterIP of `api-svc`.

---

## Task 3 — Create a PVC [target: 2 min]

**Context:** An application needs persistent storage.

**Task:** Create a PersistentVolumeClaim named `data-vol` in namespace `speed-31` with storageClassName `standard`, size `500Mi`, access mode `ReadWriteOnce`.

**Verify:**
```
kubectl get pvc data-vol -n speed-31
```

---

## Task 4 — Create a pod that mounts the PVC [target: 3 min]

**Context:** The PVC must be attached to a running pod.

**Task:** Create a pod named `data-pod` in namespace `speed-31` using image `nginx:stable`. Mount the PVC `data-vol` at path `/data`.

**Verify:**
```
kubectl get pod data-pod -n speed-31
kubectl get pvc data-vol -n speed-31
```
PVC should be `Bound`. Pod should be `Running`.

---

## Task 5 — Write a file to the mounted volume [target: 3 min]

**Context:** Confirm that the volume is writable.

**Task:** Once `data-pod` is Running, use `kubectl exec` to write the text `hello from speed-31` into a file at `/data/test.txt` inside the pod.

**Verify:**
```
kubectl exec data-pod -n speed-31 -- cat /data/test.txt
```

---

## Task 6 — Create a deny-all NetworkPolicy [target: 3 min]

**Context:** The namespace needs to be locked down by default.

**Task:** Create a NetworkPolicy named `deny-all` in namespace `speed-31` that denies all ingress traffic to all pods in the namespace.

**Verify:**
```
kubectl get networkpolicy deny-all -n speed-31
kubectl describe networkpolicy deny-all -n speed-31
```

---

## Task 7 — Create an allowlist NetworkPolicy [target: 4 min]

**Context:** After locking down the namespace, you need to re-allow traffic to the `api` pods.

**Task:** Create a NetworkPolicy named `allow-api` in namespace `speed-31` that allows ingress on port 80 to pods with label `app=api` from any pod in the same namespace (no restriction on source pod labels).

**Verify:**
```
kubectl get networkpolicy allow-api -n speed-31
kubectl describe networkpolicy allow-api -n speed-31
```

---

## Task 8 — Create a NodePort service [target: 3 min]

**Context:** External traffic needs to reach the `api` pods directly on a node port.

**Task:** Create a NodePort service named `api-nodeport` in namespace `speed-31` for pods with label `app=api`, service port 80, nodePort 30080.

**Verify:**
```
kubectl get svc api-nodeport -n speed-31
```
`NODE-PORT` column should show `80:30080/TCP`.

---

## Task 9 — List StorageClasses and identify the default [target: 1 min]

**Context:** You need to know which StorageClass will be used when no `storageClassName` is specified.

**Task:** List all StorageClasses in the cluster. Identify which one is the default.

**Verify:** Your output clearly shows which StorageClass has the `(default)` annotation.

---

## Task 10 — DNS test for kubernetes.default [target: 2 min]

**Context:** Confirm cluster-internal DNS is working for the Kubernetes API service.

**Task:** Create a pod named `nslookup-pod` in namespace `speed-31` using `busybox:stable`. Exec into it and run `nslookup kubernetes.default.svc.cluster.local`.

**Verify:** The nslookup output resolves to `10.96.0.1` (or whatever the kubernetes service ClusterIP is in your cluster).

---

## Time check

Record your finish time. Did you beat 60 minutes? Open `notes.md` and fill in your reflection.
