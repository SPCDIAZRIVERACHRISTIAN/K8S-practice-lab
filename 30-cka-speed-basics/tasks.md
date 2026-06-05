# Lab 30 — CKA Speed Basics: Tasks

**Total target time:** 45 minutes  
**Namespace:** `speed-01` (create it in Task 1)

Start a timer when you begin. Note your actual time for each task in `notes.md`.

---

## Task 1 — Create a namespace [target: 1 min]

**Context:** All subsequent tasks use namespace `speed-01`.

**Task:** Create namespace `speed-01`.

**Verify:**
```
kubectl get namespace speed-01
```

---

## Task 2 — Create a deployment [target: 2 min]

**Context:** You need a web server deployment.

**Task:** Create a deployment named `web` using image `nginx:stable` with 3 replicas in namespace `speed-01`.

**Verify:**
```
kubectl get deployment web -n speed-01
kubectl get pods -n speed-01
```

---

## Task 3 — Expose the deployment [target: 2 min]

**Context:** The deployment needs to be reachable inside the cluster.

**Task:** Expose deployment `web` as a ClusterIP service named `web-svc` on port 80 in namespace `speed-01`.

**Verify:**
```
kubectl get svc web-svc -n speed-01
kubectl get endpoints web-svc -n speed-01
```

---

## Task 4 — Scale the deployment [target: 1 min]

**Context:** Traffic has increased.

**Task:** Scale deployment `web` in namespace `speed-01` to 5 replicas.

**Verify:**
```
kubectl get deployment web -n speed-01
```

---

## Task 5 — Update the image [target: 1 min]

**Context:** A new image version is available.

**Task:** Update the image of the `web` container in deployment `web` (namespace `speed-01`) to `nginx:1.25`.

**Verify:**
```
kubectl rollout status deployment/web -n speed-01
kubectl describe deployment web -n speed-01 | grep Image
```

---

## Task 6 — Rollout history and rollback [target: 2 min]

**Context:** The new image is causing issues; you must revert.

**Task:** Check the rollout history of deployment `web` in namespace `speed-01`. Then roll back to the previous revision.

**Verify:**
```
kubectl rollout history deployment/web -n speed-01
kubectl describe deployment web -n speed-01 | grep Image
```

---

## Task 7 — Create a ConfigMap [target: 2 min]

**Context:** The application needs configuration injected at runtime.

**Task:** Create a ConfigMap named `app-config` in namespace `speed-01` with two literal key-value pairs: `env=production` and `color=blue`.

**Verify:**
```
kubectl get configmap app-config -n speed-01 -o yaml
```

---

## Task 8 — Create a Secret [target: 2 min]

**Context:** Database credentials must be stored as a Secret.

**Task:** Create a Secret named `db-creds` in namespace `speed-01` with literal values: `username=admin` and `password=s3cr3t`.

**Verify:**
```
kubectl get secret db-creds -n speed-01
kubectl get secret db-creds -n speed-01 -o jsonpath='{.data.username}' | base64 -d
```

---

## Task 9 — Create a pod with env vars from ConfigMap and Secret [target: 4 min]

**Context:** A pod needs both application config and database credentials injected as environment variables.

**Task:** Create a pod named `env-pod` in namespace `speed-01` using image `nginx:stable`. Configure it so that:
- The `env` key from ConfigMap `app-config` is injected as environment variable `APP_ENV`
- The `username` key from Secret `db-creds` is injected as environment variable `DB_USER`

**Verify:**
```
kubectl exec env-pod -n speed-01 -- env | grep -E 'APP_ENV|DB_USER'
```

---

## Task 10 — ServiceAccount and RoleBinding [target: 3 min]

**Context:** An application needs read-only access to namespace resources.

**Task:** Create ServiceAccount `speed-sa` in namespace `speed-01`. Create a RoleBinding that grants `speed-sa` the built-in `view` ClusterRole within namespace `speed-01`. Name the RoleBinding `speed-sa-view`.

**Verify:**
```
kubectl get serviceaccount speed-sa -n speed-01
kubectl get rolebinding speed-sa-view -n speed-01
kubectl auth can-i list pods --as=system:serviceaccount:speed-01:speed-sa -n speed-01
```

---

## Task 11 — List pods by label across all namespaces [target: 1 min]

**Context:** You need to find all web pods regardless of which namespace they are in.

**Task:** List all pods across all namespaces that have the label `app=web`.

**Verify:** The command produces output (or shows no resources — that is also correct if no pods carry that label).

---

## Task 12 — Generate pod YAML without creating it [target: 2 min]

**Context:** You want a YAML template to review before applying.

**Task:** Generate the YAML manifest for a pod named `preview-pod` using image `busybox:stable` with command `sleep 3600`, without creating the pod. Save the output to `/tmp/preview-pod.yaml`.

**Verify:**
```
cat /tmp/preview-pod.yaml
kubectl apply --dry-run=server -f /tmp/preview-pod.yaml
```

---

## Time check

Record your finish time. Did you beat 45 minutes? Open `notes.md` and fill in your reflection.
