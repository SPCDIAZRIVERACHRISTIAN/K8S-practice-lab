# Lab 30 — CKA Speed Basics: Solutions

---

## Task 1 — Create a namespace

```bash
kubectl create namespace speed-01
```

**Verify:**
```bash
kubectl get namespace speed-01
```

**CKA tip:** Namespace creation is a single command you should complete in under 15 seconds.

---

## Task 2 — Create a deployment

```bash
kubectl create deployment web \
  --image=nginx:stable \
  --replicas=3 \
  --namespace=speed-01
```

**Verify:**
```bash
kubectl get deployment web -n speed-01
kubectl get pods -n speed-01 -l app=web
```

**CKA tip:** `kubectl create deployment` sets the pod template label `app=<name>` automatically. You rarely need to specify labels manually at creation time for deployments.

---

## Task 3 — Expose the deployment

```bash
kubectl expose deployment web \
  --name=web-svc \
  --port=80 \
  --target-port=80 \
  --type=ClusterIP \
  --namespace=speed-01
```

**Verify:**
```bash
kubectl get svc web-svc -n speed-01
kubectl get endpoints web-svc -n speed-01
```

**CKA tip:** `kubectl expose deployment` reads the pod template labels from the deployment and sets them as the service selector automatically. Always verify endpoints are populated — if they are empty, the selector is wrong.

---

## Task 4 — Scale the deployment

```bash
kubectl scale deployment web --replicas=5 -n speed-01
```

**Verify:**
```bash
kubectl get deployment web -n speed-01
# READY column should show 5/5
```

**CKA tip:** `kubectl scale` works on deployments, replicasets, and statefulsets. Know all three.

---

## Task 5 — Update the image

```bash
kubectl set image deployment/web web=nginx:1.25 -n speed-01
```

The format is `<container-name>=<new-image>`. For deployments created with `kubectl create deployment`, the container name matches the deployment name.

**Verify:**
```bash
kubectl rollout status deployment/web -n speed-01
kubectl describe deployment web -n speed-01 | grep Image
```

**CKA tip:** If you don't know the container name, run `kubectl get deployment web -n speed-01 -o jsonpath='{.spec.template.spec.containers[0].name}'` first.

---

## Task 6 — Rollout history and rollback

```bash
# Check history
kubectl rollout history deployment/web -n speed-01

# Roll back to the previous revision
kubectl rollout undo deployment/web -n speed-01
```

To roll back to a specific revision: `kubectl rollout undo deployment/web --to-revision=1 -n speed-01`

**Verify:**
```bash
kubectl rollout history deployment/web -n speed-01
kubectl describe deployment web -n speed-01 | grep Image
# Image should be back to nginx:stable
```

**CKA tip:** `kubectl rollout undo` without `--to-revision` always goes back one step. Rollout history is only recorded if the deployment has `.spec.revisionHistoryLimit > 0` (default is 10).

---

## Task 7 — Create a ConfigMap

```bash
kubectl create configmap app-config \
  --from-literal=env=production \
  --from-literal=color=blue \
  -n speed-01
```

**Verify:**
```bash
kubectl get configmap app-config -n speed-01 -o yaml
```

**CKA tip:** `--from-literal` for individual key-value pairs. `--from-file` for files. `--from-env-file` for `.env` files. Know all three but `--from-literal` is most common in CKA tasks.

---

## Task 8 — Create a Secret

```bash
kubectl create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=s3cr3t \
  -n speed-01
```

**Verify:**
```bash
kubectl get secret db-creds -n speed-01
kubectl get secret db-creds -n speed-01 -o jsonpath='{.data.username}' | base64 -d
# Should output: admin
```

**CKA tip:** The `generic` subcommand creates an Opaque secret. Other types: `docker-registry`, `tls`. Values are base64-encoded automatically by kubectl.

---

## Task 9 — Pod with env vars from ConfigMap and Secret

This task cannot be done with a single imperative command. Generate YAML and edit it, or use `--dry-run=client -o yaml` as a starting point.

**Method 1 — dry-run + patch:**

```bash
kubectl run env-pod \
  --image=nginx:stable \
  --dry-run=client -o yaml \
  -n speed-01 > /tmp/env-pod.yaml
```

Then edit `/tmp/env-pod.yaml` to add the `env` section under the container:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
  namespace: speed-01
spec:
  containers:
  - name: env-pod
    image: nginx:stable
    env:
    - name: APP_ENV
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: env
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-creds
          key: username
```

```bash
kubectl apply -f /tmp/env-pod.yaml
```

**Verify:**
```bash
kubectl exec env-pod -n speed-01 -- env | grep -E 'APP_ENV|DB_USER'
# Expected:
# APP_ENV=production
# DB_USER=admin
```

**CKA tip:** Memorize the `valueFrom.configMapKeyRef` and `valueFrom.secretKeyRef` structures. These appear on nearly every CKA exam. The fields are: `name` (the resource name) and `key` (the data key within the resource).

To inject ALL keys from a ConfigMap or Secret at once, use `envFrom`:
```yaml
envFrom:
- configMapRef:
    name: app-config
- secretRef:
    name: db-creds
```

---

## Task 10 — ServiceAccount and RoleBinding

```bash
# Create the ServiceAccount
kubectl create serviceaccount speed-sa -n speed-01

# Create a RoleBinding using the built-in view ClusterRole
kubectl create rolebinding speed-sa-view \
  --clusterrole=view \
  --serviceaccount=speed-01:speed-sa \
  --namespace=speed-01
```

**Verify:**
```bash
kubectl get serviceaccount speed-sa -n speed-01
kubectl get rolebinding speed-sa-view -n speed-01
kubectl auth can-i list pods \
  --as=system:serviceaccount:speed-01:speed-sa \
  -n speed-01
# Should output: yes
kubectl auth can-i delete pods \
  --as=system:serviceaccount:speed-01:speed-sa \
  -n speed-01
# Should output: no
```

**CKA tip:**
- `--clusterrole` binds a ClusterRole within the namespace scope (a RoleBinding, not a ClusterRoleBinding)
- `--serviceaccount` format is `<namespace>:<serviceaccount-name>`
- Built-in roles: `view` (read-only), `edit` (read/write), `admin` (full within namespace), `cluster-admin` (full cluster)

---

## Task 11 — List pods by label across all namespaces

```bash
kubectl get pods --all-namespaces -l app=web
# Or the shorter form:
kubectl get pods -A -l app=web
```

**Verify:** Command executes successfully. Results depend on what is running.

**CKA tip:** `-A` is the short form of `--all-namespaces`. `-l` accepts multiple selectors: `-l app=web,tier=frontend`.

---

## Task 12 — Generate pod YAML without creating it

```bash
kubectl run preview-pod \
  --image=busybox:stable \
  --command \
  --dry-run=client -o yaml \
  -- sleep 3600 > /tmp/preview-pod.yaml
```

**Verify:**
```bash
cat /tmp/preview-pod.yaml
kubectl apply --dry-run=server -f /tmp/preview-pod.yaml
```

**CKA tip:** `--dry-run=client -o yaml` is the fastest way to generate a starting-point manifest. Redirect to a file, then edit and apply. The `--command` flag separates kubectl flags from the container command — arguments after `--` are passed as the container command.

---

## CKA Speed Reference

### Most-used imperative commands

| Action | Command |
|--------|---------|
| Create namespace | `kubectl create namespace <name>` |
| Create deployment | `kubectl create deployment <name> --image=<img> --replicas=<n>` |
| Expose deployment | `kubectl expose deployment <name> --port=<p> --name=<svc>` |
| Scale | `kubectl scale deployment <name> --replicas=<n>` |
| Update image | `kubectl set image deployment/<name> <container>=<img>` |
| Rollback | `kubectl rollout undo deployment/<name>` |
| Create ConfigMap | `kubectl create configmap <name> --from-literal=k=v` |
| Create Secret | `kubectl create secret generic <name> --from-literal=k=v` |
| Create ServiceAccount | `kubectl create serviceaccount <name>` |
| Create RoleBinding | `kubectl create rolebinding <name> --clusterrole=<role> --serviceaccount=<ns>:<sa>` |
| Generate YAML | `kubectl run/create ... --dry-run=client -o yaml > file.yaml` |
| Check permissions | `kubectl auth can-i <verb> <resource> --as=<identity>` |

### Always add `-n <namespace>` or set the namespace in your context

```bash
# Set default namespace for current context (saves typing during exam)
kubectl config set-context --current --namespace=<namespace>
```
