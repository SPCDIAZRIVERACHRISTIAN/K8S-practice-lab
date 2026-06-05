# Commands — 28 Troubleshoot Storage

---

## 1. Set up

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f broken/01-wrong-storageclass.yaml
kubectl apply -f broken/02-wrong-accessmode.yaml
kubectl apply -f broken/03-pod-missing-pvc.yaml
kubectl apply -f broken/04-statefulset-bad-sc.yaml
```

```bash
kubectl get pvc -n lab-28-storage
kubectl get pods -n lab-28-storage
```

> How many PVCs are in Pending? What state is the pod in?

---

## 2. Scenario 1 — Wrong StorageClass

```bash
kubectl describe pvc pvc-wrong-sc -n lab-28-storage
```

> Find the Events section. What does it say? Which provisioner is being called?

```bash
kubectl get storageclass
```

> What StorageClasses are available? Which one does kind use?

**Fix:**

```bash
kubectl patch pvc pvc-wrong-sc -n lab-28-storage \
  --type=merge \
  -p '{"spec":{"storageClassName":"standard"}}'
```

> Did the patch work? PVC specs are mostly immutable after creation — `storageClassName` cannot be changed via patch. Try this instead:

```bash
kubectl delete pvc pvc-wrong-sc -n lab-28-storage
# Edit broken/01-wrong-storageclass.yaml: change storageClassName to standard
kubectl apply -f broken/01-wrong-storageclass.yaml
kubectl get pvc pvc-wrong-sc -n lab-28-storage
```

---

## 3. Scenario 2 — Wrong Access Mode

```bash
kubectl describe pvc pvc-wrong-mode -n lab-28-storage
```

> What error appears? What access modes does the standard StorageClass support?

**Fix:** Delete and recreate with `ReadWriteOnce`:

```bash
kubectl delete pvc pvc-wrong-mode -n lab-28-storage
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-wrong-mode
  namespace: lab-28-storage
spec:
  storageClassName: standard
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF
kubectl get pvc pvc-wrong-mode -n lab-28-storage
```

---

## 4. Scenario 3 — Pod with Missing PVC

```bash
kubectl describe pod pod-missing-pvc -n lab-28-storage
```

> What does the Events section say? What specific error mentions the PVC?

**Fix:** Create the missing PVC, then watch the pod recover:

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: does-not-exist-pvc
  namespace: lab-28-storage
spec:
  storageClassName: standard
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 200Mi
EOF
kubectl get pod pod-missing-pvc -n lab-28-storage -w
```

> How long does it take the pod to start after the PVC is created? Did you need to delete and recreate the pod?

---

## 5. Scenario 4 — StatefulSet with Bad volumeClaimTemplate

```bash
kubectl get pods -n lab-28-storage -l app=broken-db
kubectl get pvc -n lab-28-storage
```

> What are the PVC names? What state are they in?

```bash
kubectl describe pvc -n lab-28-storage -l app=broken-db | grep -A 10 Events
```

> Same provisioner error as scenario 1 — but this is a StatefulSet. Can you patch the volumeClaimTemplate?

Try the patch:

```bash
kubectl patch statefulset broken-db -n lab-28-storage \
  --type=json \
  -p='[{"op":"replace","path":"/spec/volumeClaimTemplates/0/spec/storageClassName","value":"standard"}]'
```

> What error do you get? `volumeClaimTemplates` is immutable on a running StatefulSet.

**Fix:** Delete the StatefulSet AND its PVCs, then recreate:

```bash
kubectl scale statefulset broken-db --replicas=0 -n lab-28-storage
kubectl delete statefulset broken-db -n lab-28-storage
kubectl delete pvc -n lab-28-storage -l app=broken-db

# Recreate with correct storageClassName
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: broken-db
  namespace: lab-28-storage
spec:
  serviceName: broken-db-headless
  replicas: 2
  selector:
    matchLabels:
      app: broken-db
  template:
    metadata:
      labels:
        app: broken-db
    spec:
      containers:
      - name: db
        image: nginx:stable
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
        volumeMounts:
        - name: storage
          mountPath: /var/lib/data
  volumeClaimTemplates:
  - metadata:
      name: storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: standard
      resources:
        requests:
          storage: 100Mi
EOF

kubectl get pvc -n lab-28-storage
kubectl get pods -n lab-28-storage -l app=broken-db
```

---

## 6. Inspect the fixed state

```bash
kubectl get pvc -n lab-28-storage
kubectl get pods -n lab-28-storage
```

> All PVCs should be Bound. All pods should be Running.

```bash
kubectl get pv | grep lab-28
```

> How many PersistentVolumes were created? Who created them?
