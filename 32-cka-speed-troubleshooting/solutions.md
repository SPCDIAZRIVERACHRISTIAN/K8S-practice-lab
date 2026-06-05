# Lab 32 — CKA Speed Troubleshooting: Solutions

---

## Task 1 — app-a: ImagePullBackOff

### Diagnosis

```bash
kubectl get pods -n speed-32 -l app=app-a
# STATUS: ImagePullBackOff or ErrImagePull

kubectl describe pod -n speed-32 -l app=app-a
# Events section:
#   Warning  Failed  ...  Failed to pull image "nginx:badtag-9999": ...
#   Warning  Failed  ...  Error: ErrImagePull
```

**Root cause:** The deployment uses image `nginx:badtag-9999`, which does not exist in the registry.

### Fix

```bash
kubectl set image deployment/app-a app-a=nginx:stable -n speed-32
```

### Verification

```bash
kubectl rollout status deployment/app-a -n speed-32
kubectl get pods -n speed-32 -l app=app-a
# Both pods: Running
```

**Diagnostic pattern:** For ImagePullBackOff, always check `kubectl describe pod` Events → look for the image name in the error → fix with `kubectl set image`.

---

## Task 2 — app-b-svc: No endpoints

### Diagnosis

```bash
kubectl get endpoints app-b-svc -n speed-32
# Endpoints: <none>

kubectl describe svc app-b-svc -n speed-32
# Selector: app=app-bb   ← note the typo

kubectl get pods -n speed-32 --show-labels
# The app-b pods have label: app=app-b   ← does not match
```

**Root cause:** The service selector is `app: app-bb` but the pods have label `app: app-b`. The extra `b` means the selector matches nothing.

### Fix

```bash
kubectl patch svc app-b-svc -n speed-32 \
  --type=json \
  -p='[{"op":"replace","path":"/spec/selector/app","value":"app-b"}]'
```

Or edit directly:
```bash
kubectl edit svc app-b-svc -n speed-32
# Change: app: app-bb → app: app-b
```

### Verification

```bash
kubectl get endpoints app-b-svc -n speed-32
# Should now list pod IP addresses
```

**Diagnostic pattern:** When a service has no endpoints, compare `kubectl describe svc` Selector field vs `kubectl get pods --show-labels`. Label mismatches are the #1 cause of empty endpoints.

---

## Task 3 — app-c: CreateContainerConfigError

### Diagnosis

```bash
kubectl get pod app-c -n speed-32
# STATUS: CreateContainerConfigError

kubectl describe pod app-c -n speed-32
# Events:
#   Warning  Failed  ...  Error: couldn't find key mode in ConfigMap speed-32/app-config

kubectl get configmap app-config -n speed-32 -o yaml
# data:
#   MODE: production   ← key is uppercase MODE, not mode
```

**Root cause:** The pod references key `mode` (lowercase) in the ConfigMap, but the actual key is `MODE` (uppercase). Key lookups are case-sensitive.

### Fix

Since the pod is already created and pods are immutable for environment variable references, delete and recreate the pod with the correct key name.

```bash
kubectl delete pod app-c -n speed-32
```

Create a corrected pod manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-c
  namespace: speed-32
spec:
  containers:
  - name: app-c
    image: nginx:stable
    env:
    - name: APP_MODE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: MODE
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-c
  namespace: speed-32
spec:
  containers:
  - name: app-c
    image: nginx:stable
    env:
    - name: APP_MODE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: MODE
EOF
```

### Verification

```bash
kubectl get pod app-c -n speed-32
# STATUS: Running

kubectl exec app-c -n speed-32 -- env | grep APP_MODE
# APP_MODE=production
```

**Diagnostic pattern:** `CreateContainerConfigError` almost always means a missing ConfigMap/Secret key, a missing ConfigMap/Secret entirely, or a wrong name. Read the Events section of `kubectl describe pod` — it will name the missing key or resource.

---

## Task 4 — app-d: Pending

### Diagnosis

```bash
kubectl get pod app-d -n speed-32
# STATUS: Pending

kubectl describe pod app-d -n speed-32
# Events:
#   Warning  FailedScheduling  ...  0/3 nodes are available:
#             3 Insufficient cpu, 3 Insufficient memory.

kubectl describe pod app-d -n speed-32 | grep -A5 Requests
# Requests:
#   cpu:     100
#   memory:  500Gi
```

**Root cause:** The pod requests `100` CPU (100 full cores) and `500Gi` memory. No node in a kind cluster has this capacity. The scheduler cannot place the pod.

### Fix

Delete the pod and recreate with sane resource requests:

```bash
kubectl delete pod app-d -n speed-32
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-d
  namespace: speed-32
spec:
  containers:
  - name: app-d
    image: nginx:stable
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
EOF
```

### Verification

```bash
kubectl get pod app-d -n speed-32
# STATUS: Running
```

**Diagnostic pattern:** Pending pods → check `kubectl describe pod` Events → `FailedScheduling` with `Insufficient cpu/memory` → the resource requests are too large. Common mistake: `cpu: "100"` means 100 cores, not 100 millicores. Use `"100m"` for 0.1 CPU.

---

## Task 5 — app-e: Restarting (bad liveness probe)

### Diagnosis

```bash
kubectl get pods -n speed-32 -l app=app-e
# RESTARTS column is increasing

kubectl describe pod -n speed-32 -l app=app-e
# Liveness: http-get http://:9999/healthcheck delay=3s timeout=1s period=5s ...
# Events:
#   Warning  Unhealthy  ...  Liveness probe failed: Get "http://...9999/healthcheck": dial tcp ...:9999: connect: connection refused
#   Normal   Killing    ...  Container app-e failed liveness probe, will be restarted
```

**Root cause:** The liveness probe targets port 9999 with path `/healthcheck`. The nginx container only listens on port 80 and does not have a `/healthcheck` endpoint. Every probe fails, so Kubernetes kills and restarts the container indefinitely.

### Fix

```bash
kubectl edit deployment app-e -n speed-32
# Change the livenessProbe:
#   port: 9999  →  port: 80
#   path: /healthcheck  →  path: /
```

Or patch:
```bash
kubectl patch deployment app-e -n speed-32 \
  --type=json \
  -p='[
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/port","value":80},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/"}
  ]'
```

### Verification

```bash
kubectl rollout status deployment/app-e -n speed-32
kubectl get pods -n speed-32 -l app=app-e
# STATUS: Running, RESTARTS not increasing
kubectl describe pod -n speed-32 -l app=app-e | grep -A5 Liveness
# Liveness: http-get http://:80/ ...
```

**Diagnostic pattern:** High restart count → check `kubectl describe pod` Events for `Unhealthy` (liveness) or `Startup probe failed` → identify the probe port and path → verify against the actual container port/path.
