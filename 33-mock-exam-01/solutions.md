# Mock Exam 01 — Solutions

**Total points:** 65  
**Score guide:** 60+ = exam-ready | 50–59 = almost ready | < 50 = review weak areas

---

## Task 1 [2 points]

```bash
kubectl create namespace exam-01
```

---

## Task 2 [3 points]

```bash
kubectl run web-pod \
  --image=nginx:stable \
  --labels=tier=frontend \
  --namespace=exam-01
```

The `default` ServiceAccount is used automatically when no serviceAccountName is specified. Verify:

```bash
kubectl get pod web-pod -n exam-01 -o jsonpath='{.spec.serviceAccountName}'
# default
kubectl get pod web-pod -n exam-01 --show-labels
# tier=frontend
```

---

## Task 3 [5 points]

```bash
kubectl create deployment web-deploy \
  --image=nginx:stable \
  --replicas=3 \
  --namespace=exam-01
```

Then add resource requests. Generate YAML, edit, and apply:

```bash
kubectl get deployment web-deploy -n exam-01 -o yaml > /tmp/web-deploy.yaml
```

Edit `/tmp/web-deploy.yaml` to add under `containers[0]`:
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
```

Also ensure the pod template has `app=web` label (set automatically by `kubectl create deployment` using the deployment name — since it's named `web-deploy` the label will be `app=web-deploy`, not `app=web`). You must patch it:

```bash
kubectl patch deployment web-deploy -n exam-01 \
  --type=json \
  -p='[{"op":"replace","path":"/spec/template/metadata/labels/app","value":"web"}]'
```

Or do it all at once with a manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
  namespace: exam-01
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web-deploy
        image: nginx:stable
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
```

**Verify:**
```bash
kubectl get deployment web-deploy -n exam-01
kubectl describe deployment web-deploy -n exam-01 | grep -A4 Requests
kubectl get pods -n exam-01 -l app=web
```

---

## Task 4 [3 points]

```bash
kubectl scale deployment web-deploy --replicas=5 -n exam-01
kubectl set image deployment/web-deploy web-deploy=nginx:1.25 -n exam-01
kubectl rollout status deployment/web-deploy -n exam-01
```

**Verify:**
```bash
kubectl get deployment web-deploy -n exam-01
# READY: 5/5
kubectl describe deployment web-deploy -n exam-01 | grep Image
# Image: nginx:1.25
```

---

## Task 5 [4 points]

```bash
kubectl expose deployment web-deploy \
  --name=web-svc \
  --type=NodePort \
  --port=80 \
  --target-port=80 \
  --namespace=exam-01
```

Then patch the nodePort:
```bash
kubectl patch svc web-svc -n exam-01 \
  --type=json \
  -p='[{"op":"replace","path":"/spec/ports/0/nodePort","value":30090}]'
```

Or write the service YAML directly:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: exam-01
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30090
```

**Verify:**
```bash
kubectl get svc web-svc -n exam-01
# PORT(S): 80:30090/TCP
```

---

## Task 6 [4 points]

```bash
kubectl create configmap app-settings \
  --from-literal=log_level=INFO \
  --from-literal=max_connections=100 \
  -n exam-01
```

Pod with `envFrom`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configured-pod
  namespace: exam-01
spec:
  containers:
  - name: configured-pod
    image: busybox:stable
    command: ["sleep", "3600"]
    envFrom:
    - configMapRef:
        name: app-settings
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: configured-pod
  namespace: exam-01
spec:
  containers:
  - name: configured-pod
    image: busybox:stable
    command: ["sleep", "3600"]
    envFrom:
    - configMapRef:
        name: app-settings
EOF
```

**Verify:**
```bash
kubectl exec configured-pod -n exam-01 -- env | grep -E 'log_level|max_connections'
# log_level=INFO
# max_connections=100
```

---

## Task 7 [4 points]

```bash
kubectl create secret generic db-secret \
  --from-literal=DB_HOST=db.internal \
  --from-literal=DB_PASS='p@ssw0rd' \
  -n exam-01
```

Pod with secret volume mount:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: exam-01
spec:
  containers:
  - name: secret-pod
    image: nginx:stable
    volumeMounts:
    - name: db-config
      mountPath: /etc/db-config
      readOnly: true
  volumes:
  - name: db-config
    secret:
      secretName: db-secret
EOF
```

**Verify:**
```bash
kubectl get pod secret-pod -n exam-01
kubectl exec secret-pod -n exam-01 -- ls /etc/db-config
# DB_HOST  DB_PASS
kubectl exec secret-pod -n exam-01 -- cat /etc/db-config/DB_HOST
# db.internal
```

---

## Task 8 [4 points]

```bash
kubectl create serviceaccount app-sa -n exam-01

kubectl create role app-role \
  --verb=get,list,watch \
  --resource=pods,configmaps \
  -n exam-01

kubectl create rolebinding app-sa-binding \
  --role=app-role \
  --serviceaccount=exam-01:app-sa \
  -n exam-01
```

**Verify:**
```bash
kubectl get serviceaccount app-sa -n exam-01
kubectl get role app-role -n exam-01
kubectl get rolebinding app-sa-binding -n exam-01
```

---

## Task 9 [3 points]

```bash
kubectl auth can-i list pods \
  --as=system:serviceaccount:exam-01:app-sa \
  -n exam-01
# yes

kubectl auth can-i delete pods \
  --as=system:serviceaccount:exam-01:app-sa \
  -n exam-01
# no
```

---

## Task 10 [4 points]

PVC:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage
  namespace: exam-01
spec:
  storageClassName: standard
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

Pod:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
  namespace: exam-01
spec:
  containers:
  - name: storage-pod
    image: nginx:stable
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: app-storage
EOF
```

**Verify:**
```bash
kubectl get pvc app-storage -n exam-01
# STATUS: Bound
kubectl get pod storage-pod -n exam-01
# STATUS: Running
```

---

## Task 11 [3 points]

```bash
kubectl create cronjob cleanup-job \
  --image=busybox:stable \
  --schedule='*/5 * * * *' \
  --namespace=exam-01 \
  -- echo "cleanup complete"
```

**Verify:**
```bash
kubectl get cronjob cleanup-job -n exam-01
kubectl describe cronjob cleanup-job -n exam-01
```

---

## Task 12 [5 points]

Deny-all:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: exam-01
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF
```

Allow-web (ingress on port 80 to `app=web` from `tier=frontend`):
```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web
  namespace: exam-01
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
EOF
```

**Verify:**
```bash
kubectl get networkpolicy -n exam-01
kubectl describe networkpolicy deny-all -n exam-01
kubectl describe networkpolicy allow-web -n exam-01
```

---

## Task 13 [4 points]

```bash
# Add taint
kubectl taint node kind-worker env=test:NoSchedule

# Create pod with toleration
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: tolerant-pod
  namespace: exam-01
spec:
  tolerations:
  - key: "env"
    operator: "Equal"
    value: "test"
    effect: "NoSchedule"
  containers:
  - name: tolerant-pod
    image: nginx:stable
EOF
```

**Verify:**
```bash
kubectl get pod tolerant-pod -n exam-01 -o wide
# NODE column should show kind-worker
```

```bash
# Remove the taint
kubectl taint node kind-worker env=test:NoSchedule-
```

---

## Task 14 [3 points]

```bash
# Cordon kind-worker2
kubectl cordon kind-worker2

# Create a test pod
kubectl run cordon-test \
  --image=nginx:stable \
  --namespace=exam-01
```

**Verify:**
```bash
kubectl get pod cordon-test -n exam-01 -o wide
# NODE should be kind-worker (not kind-worker2, not kind-control-plane)
```

```bash
# Uncordon
kubectl uncordon kind-worker2
```

---

## Task 15 [5 points]

```bash
# Create namespace and broken deployment
kubectl create namespace exam-01-broken
kubectl create deployment broken-deploy \
  --image=nginx:broken-tag \
  --replicas=2 \
  --namespace=exam-01-broken

# Verify it's failing
kubectl get pods -n exam-01-broken
# ImagePullBackOff

# Fix the image
kubectl set image deployment/broken-deploy \
  broken-deploy=nginx:stable \
  -n exam-01-broken

kubectl rollout status deployment/broken-deploy -n exam-01-broken
```

**Verify:**
```bash
kubectl get pods -n exam-01-broken
# 2/2 Running
```

---

## Task 16 [4 points]

Headless Service:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: stateful-svc
  namespace: exam-01
spec:
  clusterIP: None
  selector:
    app: stateful-app
  ports:
  - port: 80
    targetPort: 80
EOF
```

StatefulSet with volumeClaimTemplate:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: stateful-app
  namespace: exam-01
spec:
  serviceName: stateful-svc
  replicas: 2
  selector:
    matchLabels:
      app: stateful-app
  template:
    metadata:
      labels:
        app: stateful-app
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      storageClassName: standard
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
EOF
```

**Verify:**
```bash
kubectl get statefulset stateful-app -n exam-01
kubectl get pods -n exam-01 -l app=stateful-app
# stateful-app-0 and stateful-app-1: Running
kubectl get pvc -n exam-01 | grep data-stateful
# data-stateful-app-0 and data-stateful-app-1: Bound
```

---

## Task 17 [5 points]

etcd runs as a static pod on the control-plane in kind. Use `kubectl exec` to access it:

```bash
# Find the etcd pod
kubectl get pods -n kube-system | grep etcd

# Get etcd endpoint and cert paths from the etcd pod spec
kubectl describe pod etcd-kind-control-plane -n kube-system | grep -E 'listen-client|cert-file|key-file|trusted-ca'
```

Take the snapshot by execing into the control-plane container:

```bash
docker exec kind-control-plane etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-exam-backup.db
```

The file is saved inside the container. Copy it out if needed:
```bash
docker cp kind-control-plane:/tmp/etcd-exam-backup.db /tmp/etcd-exam-backup.db
```

Verify the snapshot:
```bash
docker exec kind-control-plane etcdctl \
  snapshot status /tmp/etcd-exam-backup.db \
  --write-out=table
```

Expected output shows: snapshot hash, revision, total keys, total size.

**Note:** On a real CKA exam (kubeadm cluster), etcd is also a static pod. The cert paths are the same. The `etcdctl` binary may be available directly on the node or you exec into the etcd pod.

---

## Scoring

| Task | Points | Self-score |
|------|--------|-----------|
| 1 | 2 | |
| 2 | 3 | |
| 3 | 5 | |
| 4 | 3 | |
| 5 | 4 | |
| 6 | 4 | |
| 7 | 4 | |
| 8 | 4 | |
| 9 | 3 | |
| 10 | 4 | |
| 11 | 3 | |
| 12 | 5 | |
| 13 | 4 | |
| 14 | 3 | |
| 15 | 5 | |
| 16 | 4 | |
| 17 | 5 | |
| **Total** | **65** | |
