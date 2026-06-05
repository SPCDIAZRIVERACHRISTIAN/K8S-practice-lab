# Solutions — Mock Exam 02 Hard

Total: 62 points.  
Score guide: 58+ = exam-ready, 48–57 = nearly there, <48 = review weak areas.

---

## Task 1 [3 points] — Static pods

```bash
kubectl create namespace exam-02

kubectl get pods -n kube-system \
  --field-selector spec.nodeName=kind-control-plane \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' \
  | grep -E '\-kind\-control\-plane$' \
  > /tmp/static-pods.txt

cat /tmp/static-pods.txt
```

Expected output includes: `etcd-kind-control-plane`, `kube-apiserver-kind-control-plane`, `kube-controller-manager-kind-control-plane`, `kube-scheduler-kind-control-plane`.

Static pods have their node name appended to the pod name. Mirror pods (created by kubelet from static pod manifests) are visible via kubectl but have `ownerReferences` pointing to `Node/<name>`.

---

## Task 2 [5 points] — CrashLoopBackOff fix with ConfigMap volume

```bash
# Create the pod that will crash
kubectl run mystery-pod -n exam-02 \
  --image=busybox:stable \
  --command -- sh -c "cat /etc/config/settings.json"

# Wait for it to CrashLoopBackOff, then diagnose
kubectl logs mystery-pod -n exam-02 --previous
# Output: "cat: /etc/config/settings.json: No such file or directory"

# Create the ConfigMap
kubectl create configmap pod-config \
  --from-literal=settings.json='{}' \
  -n exam-02

# Delete the crashing pod and recreate with volume mount and fixed command
kubectl delete pod mystery-pod -n exam-02

kubectl apply -n exam-02 -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: mystery-pod
  namespace: exam-02
spec:
  containers:
  - name: busybox
    image: busybox:stable
    command: ["sleep", "3600"]
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: pod-config
EOF

kubectl get pod mystery-pod -n exam-02
```

---

## Task 3 [4 points] — Fix bad liveness probe port

```bash
# Create the deployment with the broken probe
kubectl apply -n exam-02 -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: exam-02
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
EOF

# Observe pods getting killed, then fix
kubectl set env deployment/api-server -n exam-02 DUMMY=1  # no-op to trigger edit
# Or just patch the probe:
kubectl patch deployment api-server -n exam-02 \
  --type=json \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/port","value":80}]'

kubectl rollout status deployment/api-server -n exam-02
kubectl get pods -n exam-02 -l app=api-server
```

---

## Task 4 [5 points] — PDB + drain + uncordon

```bash
# Create deployment and PDB
kubectl create deployment frontend --image=nginx:stable --replicas=3 -n exam-02

kubectl apply -n exam-02 -f - <<EOF
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: frontend-pdb
  namespace: exam-02
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: frontend
EOF

# Cordon kind-worker2 (so drained pods go there)
kubectl cordon kind-worker2

# Drain kind-worker
kubectl drain kind-worker \
  --ignore-daemonsets \
  --delete-emptydir-data

# Verify
kubectl get pods -n exam-02 -l app=frontend -o wide

# Restore
kubectl uncordon kind-worker
kubectl uncordon kind-worker2
```

With `minAvailable: 2` and 3 replicas, ALLOWED DISRUPTIONS = 1. Drain evicts one pod at a time. Each eviction waits until the replacement is Ready before evicting the next. Since `kind-worker2` is cordoned, the scheduler places replacements there — wait, actually if we cordon kind-worker2 first, then drain kind-worker, the pods on kind-worker have nowhere to go (kind-worker is being drained, kind-worker2 is cordoned). 

**Correction:** Cordon `kind-worker2` is wrong here — we want pods to go TO `kind-worker2`. The correct sequence:
1. Do NOT cordon `kind-worker2` before drain
2. `kubectl drain kind-worker --ignore-daemonsets --delete-emptydir-data`
3. Pods reschedule onto `kind-worker2`
4. `kubectl uncordon kind-worker`

The task mentions cordon `kind-worker2` then drain `kind-worker` — if taken literally, this would cause pods to be Pending (no valid node). On the real CKA, re-read carefully: it likely means to prepare `kind-worker2` as the target by NOT cordoning it. Accept either interpretation as long as the result is 3 Running pods.

---

## Task 5 [4 points] — ClusterRole for cluster-scoped resources

```bash
kubectl create serviceaccount reader-sa -n exam-02

kubectl create clusterrole cluster-reader \
  --verb=get,list,watch \
  --resource=nodes,persistentvolumes,storageclasses

kubectl create clusterrolebinding cluster-reader-binding \
  --clusterrole=cluster-reader \
  --serviceaccount=exam-02:reader-sa

kubectl auth can-i list nodes \
  --as=system:serviceaccount:exam-02:reader-sa
# Expected: yes
```

Note: `nodes`, `persistentvolumes`, and `storageclasses` are cluster-scoped resources — they live at `apiGroups: [""]` (nodes, PVs) and `apiGroups: ["storage.k8s.io"]` (StorageClasses). The imperative `kubectl create clusterrole` handles the API groups automatically.

---

## Task 6 [3 points] — Fix Pending PVC (wrong StorageClass)

```bash
# Create the broken PVC
kubectl apply -n exam-02 -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: stuck-pvc
  namespace: exam-02
spec:
  storageClassName: fast-storage
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
EOF

kubectl get pvc stuck-pvc -n exam-02
# Status: Pending

kubectl describe pvc stuck-pvc -n exam-02 | grep -A 5 Events
# Events: ProvisioningFailed — storageclass.storage.k8s.io "fast-storage" not found

# Fix: delete and recreate (storageClassName is immutable)
kubectl delete pvc stuck-pvc -n exam-02
kubectl apply -n exam-02 -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: stuck-pvc
  namespace: exam-02
spec:
  storageClassName: standard
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
EOF

kubectl get pvc stuck-pvc -n exam-02
# Status: Bound (after a pod references it, due to WaitForFirstConsumer)
```

---

## Task 7 [5 points] — StatefulSet with headless Service and per-pod DNS

```bash
# Headless Service first
kubectl apply -n exam-02 -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: cache-headless
  namespace: exam-02
spec:
  clusterIP: None
  selector:
    app: cache
  ports:
  - port: 80
EOF

# StatefulSet
kubectl apply -n exam-02 -f - <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cache
  namespace: exam-02
spec:
  serviceName: cache-headless
  replicas: 3
  selector:
    matchLabels:
      app: cache
  template:
    metadata:
      labels:
        app: cache
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
  volumeClaimTemplates:
  - metadata:
      name: cache-data
    spec:
      accessModes: [ReadWriteOnce]
      storageClassName: standard
      resources:
        requests:
          storage: 50Mi
EOF

kubectl get pods -n exam-02 -l app=cache
kubectl get pvc -n exam-02

# Verify per-pod DNS
kubectl run dns-test --image=busybox:stable --rm -it --restart=Never -n exam-02 \
  -- nslookup cache-0.cache-headless.exam-02.svc.cluster.local
```

---

## Task 8 [4 points] — Node affinity pinned to labelled node

```bash
kubectl label node kind-worker zone=east

kubectl apply -n exam-02 -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zonal-app
  namespace: exam-02
spec:
  replicas: 2
  selector:
    matchLabels:
      app: zonal-app
  template:
    metadata:
      labels:
        app: zonal-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: zone
                operator: In
                values: [east]
      containers:
      - name: nginx
        image: nginx:stable
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
EOF

kubectl get pods -n exam-02 -l app=zonal-app -o wide
# Both pods should be on kind-worker

# Cleanup
kubectl label node kind-worker zone-
```

---

## Task 9 [3 points] — etcd snapshot

```bash
ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd \
  -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl snapshot save /tmp/etcd-hard-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl snapshot status /tmp/etcd-hard-backup.db \
  --write-out=table \
  | tee /tmp/etcd-status.txt
```

Record from the table: `Revision`, `Keys`, `Size` values.

---

## Task 10 [4 points] — Certificate expiry audit

```bash
docker exec kind-control-plane kubeadm certs check-expiration \
  | tee /tmp/cert-expiry.txt
```

Identify the line with the earliest `EXPIRATION` date. Component certs (apiserver, controller-manager, scheduler, etcd) typically expire after 1 year. The CA certs expire after 10 years.

Example output line:
```
admin.conf                      Nov 07, 2025 12:00 UTC   364d
```

Write the certificate name and expiry date to `/tmp/cert-expiry.txt` (already captured by `tee` above, or write just the relevant line).

---

## Task 11 [5 points] — Three-tier NetworkPolicy

```bash
kubectl create namespace exam-02-net

# default-deny
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: exam-02-net
spec:
  podSelector: {}
  policyTypes: [Ingress]
EOF

# allow-web: client → web on port 80
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web
  namespace: exam-02-net
spec:
  podSelector:
    matchLabels:
      role: web
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: client
    ports:
    - port: 80
EOF

# allow-db: web → db on port 3306
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-db
  namespace: exam-02-net
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: web
    ports:
    - port: 3306
EOF

# Create the pods
kubectl run client-pod --image=busybox:stable --labels=role=client \
  --command -- sleep 3600 -n exam-02-net
kubectl run web-pod --image=busybox:stable --labels=role=web \
  --command -- sleep 3600 -n exam-02-net
kubectl run db-pod --image=busybox:stable --labels=role=db \
  --command -- sleep 3600 -n exam-02-net
```

Note: NetworkPolicy enforcement requires a CNI that supports it (Calico, Cilium). kind's default kindnet does not enforce NetworkPolicies — the policies are accepted by the API server but have no effect.

---

## Task 12 [4 points] — CronJob + manual Job

```bash
kubectl create cronjob report-gen \
  --image=busybox:stable \
  --schedule="0 6 * * *" \
  --namespace=exam-02 \
  -- sh -c 'echo "report generated at $(date)"'

# Manually trigger a Job from the CronJob
kubectl create job report-gen-manual \
  --from=cronjob/report-gen \
  -n exam-02

kubectl get job report-gen-manual -n exam-02
kubectl wait --for=condition=complete job/report-gen-manual -n exam-02 --timeout=60s
kubectl logs -l job-name=report-gen-manual -n exam-02
```

---

## Task 13 [3 points] — Fix unschedulable pod (excessive resources)

```bash
# Create the broken deployment
kubectl create deployment heavy-app \
  --image=nginx:stable \
  --replicas=1 \
  -n exam-02

kubectl patch deployment heavy-app -n exam-02 \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/resources","value":{"requests":{"cpu":"200","memory":"1000Gi"}}}]'

kubectl get pods -n exam-02 -l app=heavy-app
# Status: Pending

kubectl describe pod -n exam-02 -l app=heavy-app | grep -A 5 Events
# Events: Insufficient cpu, Insufficient memory

# Fix
kubectl set resources deployment heavy-app -n exam-02 \
  --requests=cpu=200m,memory=256Mi

kubectl get pods -n exam-02 -l app=heavy-app
```

---

## Task 14 [5 points] — Kustomize at /tmp/kustomize-exam/

```bash
mkdir -p /tmp/kustomize-exam/base
mkdir -p /tmp/kustomize-exam/overlays/dev
mkdir -p /tmp/kustomize-exam/overlays/prod

# base/deployment.yaml
cat > /tmp/kustomize-exam/base/deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kustomized-app
  namespace: exam-02
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kustomized-app
  template:
    metadata:
      labels:
        app: kustomized-app
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
EOF

cat > /tmp/kustomize-exam/base/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
EOF

cat > /tmp/kustomize-exam/overlays/dev/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
images:
- name: nginx
  newTag: "1.25"
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 1
  target:
    kind: Deployment
    name: kustomized-app
EOF

cat > /tmp/kustomize-exam/overlays/prod/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
images:
- name: nginx
  newTag: stable
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
  target:
    kind: Deployment
    name: kustomized-app
EOF

# Apply prod overlay
kubectl apply -k /tmp/kustomize-exam/overlays/prod

kubectl get deployment kustomized-app -n exam-02
# Should show 3 replicas
```

---

## Task 15 [5 points] — Fix broken service selector

```bash
# Create the app with correct labels
kubectl create deployment mystery-app \
  --image=nginx:stable \
  --replicas=2 \
  -n exam-02-net

kubectl patch deployment mystery-app -n exam-02-net \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/metadata/labels/app","value":"mystery"}]'

# Create service with intentional typo in selector
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: mystery-svc
  namespace: exam-02-net
spec:
  selector:
    app: mysterio
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl get endpoints mystery-svc -n exam-02-net
# ENDPOINTS column is empty

kubectl describe svc mystery-svc -n exam-02-net | grep Selector
# Shows: app=mysterio (wrong)

kubectl get pods -n exam-02-net --show-labels | grep mystery
# Shows: app=mystery (correct on pods)

# Fix the selector
kubectl patch svc mystery-svc -n exam-02-net \
  --type=merge \
  -p '{"spec":{"selector":{"app":"mystery"}}}'

kubectl get endpoints mystery-svc -n exam-02-net
# ENDPOINTS now shows pod IPs
```
