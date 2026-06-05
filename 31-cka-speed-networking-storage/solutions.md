# Lab 31 — CKA Speed Networking & Storage: Solutions

---

## Task 1 — Create a ClusterIP service with port mapping

```bash
kubectl create service clusterip api-svc \
  --tcp=8080:80 \
  -n speed-31
```

Or using `expose` with a selector override:
```bash
kubectl expose deployment api \
  --name=api-svc \
  --port=8080 \
  --target-port=80 \
  --type=ClusterIP \
  -n speed-31
```

**Note:** `kubectl create service clusterip` does NOT automatically set selectors. Use `kubectl expose deployment` to inherit the correct selector from the deployment.

**Verify:**
```bash
kubectl get svc api-svc -n speed-31
kubectl get endpoints api-svc -n speed-31
# Endpoints should list pod IPs
```

---

## Task 2 — DNS resolution from inside a temporary pod

```bash
kubectl run dns-test \
  --image=busybox:stable \
  --rm -it \
  --restart=Never \
  -n speed-31 \
  -- nslookup api-svc.speed-31.svc.cluster.local
```

Or interactively:
```bash
kubectl run dns-test \
  --image=busybox:stable \
  --rm -it \
  --restart=Never \
  -n speed-31 \
  -- sh
# then inside the pod:
nslookup api-svc.speed-31.svc.cluster.local
```

**Expected output includes:**
```
Name:      api-svc.speed-31.svc.cluster.local
Address 1: 10.96.x.x
```

**CKA tip:** `--rm -it --restart=Never` is the standard pattern for one-shot debugging pods. `--rm` deletes the pod on exit. `--restart=Never` ensures it is created as a Pod (not a Deployment).

---

## Task 3 — Create a PVC

PVCs cannot be created with a single imperative command. Write the YAML:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-vol
  namespace: speed-31
spec:
  storageClassName: standard
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF
```

**Verify:**
```bash
kubectl get pvc data-vol -n speed-31
# STATUS should be Pending initially, then Bound once a pod uses it (with dynamic provisioning it may bind immediately)
```

**CKA tip:** Memorize the PVC skeleton — it's one of the most frequently written manifests in the CKA. The key fields: `storageClassName`, `accessModes` (list), `resources.requests.storage`.

---

## Task 4 — Create a pod that mounts the PVC

```bash
kubectl run data-pod \
  --image=nginx:stable \
  --dry-run=client -o yaml \
  -n speed-31 > /tmp/data-pod.yaml
```

Edit `/tmp/data-pod.yaml` to add the volume and mount:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
  namespace: speed-31
spec:
  containers:
  - name: data-pod
    image: nginx:stable
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-vol
```

```bash
kubectl apply -f /tmp/data-pod.yaml
```

**Verify:**
```bash
kubectl get pod data-pod -n speed-31
kubectl get pvc data-vol -n speed-31
# Pod: Running, PVC: Bound
```

---

## Task 5 — Write a file to the mounted volume

```bash
kubectl exec data-pod -n speed-31 -- \
  sh -c 'echo "hello from speed-31" > /data/test.txt'
```

**Verify:**
```bash
kubectl exec data-pod -n speed-31 -- cat /data/test.txt
# Output: hello from speed-31
```

---

## Task 6 — Deny-all NetworkPolicy

NetworkPolicies cannot be created imperatively. Write the YAML:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: speed-31
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF
```

**Key pattern:** `podSelector: {}` selects ALL pods. An empty `ingress` list (or absent `ingress` key) with `policyTypes: [Ingress]` means deny all ingress.

**Verify:**
```bash
kubectl get networkpolicy deny-all -n speed-31
kubectl describe networkpolicy deny-all -n speed-31
```

---

## Task 7 — Allow ingress to api pods from within the namespace

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api
  namespace: speed-31
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 80
EOF
```

**Key pattern:** `from: [{podSelector: {}}]` allows any pod in the same namespace. To restrict to a specific namespace add `namespaceSelector`.

**Verify:**
```bash
kubectl describe networkpolicy allow-api -n speed-31
```

---

## Task 8 — Create a NodePort service

```bash
kubectl create service nodeport api-nodeport \
  --tcp=80:80 \
  --node-port=30080 \
  -n speed-31
```

Then patch the selector to match the `api` pods:
```bash
kubectl patch svc api-nodeport -n speed-31 \
  --type=json \
  -p='[{"op":"replace","path":"/spec/selector","value":{"app":"api"}}]'
```

Or write it directly as YAML:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: api-nodeport
  namespace: speed-31
spec:
  type: NodePort
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF
```

**Verify:**
```bash
kubectl get svc api-nodeport -n speed-31
# PORT(S) column: 80:30080/TCP
```

---

## Task 9 — List StorageClasses and identify the default

```bash
kubectl get storageclass
# or
kubectl get sc
```

**Expected output (kind cluster):**
```
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  ...
```

The `(default)` annotation appears next to the default StorageClass name.

To see the annotation directly:
```bash
kubectl get sc standard -o jsonpath='{.metadata.annotations}'
# Look for: storageclass.kubernetes.io/is-default-class: "true"
```

---

## Task 10 — DNS test for kubernetes.default

```bash
# Create the pod
kubectl run nslookup-pod \
  --image=busybox:stable \
  --restart=Never \
  -n speed-31 \
  -- sleep 3600

# Wait for it to be Running
kubectl wait pod nslookup-pod -n speed-31 --for=condition=Ready --timeout=30s

# Run nslookup from inside
kubectl exec nslookup-pod -n speed-31 -- nslookup kubernetes.default.svc.cluster.local
```

**Expected output:**
```
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes.default.svc.cluster.local
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

---

## NetworkPolicy Reference

### Pattern 1: Deny all ingress to all pods
```yaml
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

### Pattern 2: Deny all egress from all pods
```yaml
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

### Pattern 3: Allow ingress from same namespace only
```yaml
spec:
  podSelector:
    matchLabels:
      app: myapp
  ingress:
  - from:
    - podSelector: {}
    ports:
    - port: 80
```

### Pattern 4: Allow ingress from specific namespace
```yaml
spec:
  podSelector:
    matchLabels:
      app: myapp
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: allowed-ns
    ports:
    - port: 80
```

### Pattern 5: Allow ingress from specific pods in specific namespace
```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: client-ns
    podSelector:
      matchLabels:
        role: client
```

**Important:** `namespaceSelector` + `podSelector` in the SAME list item = AND (both must match). In SEPARATE list items = OR.
