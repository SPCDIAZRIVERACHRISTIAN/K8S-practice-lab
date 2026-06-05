# Commands — 99 Capstone: Microservice Platform

Work through each section. This lab has less hand-holding than earlier ones — figure out the right commands yourself and check solutions.md only when stuck.

---

## Phase 1: Deploy the platform

### 1.1 Apply all manifests in dependency order

```bash
# Namespace first
kubectl apply -f manifests/namespace.yaml

# Config and secrets before deployments that depend on them
kubectl apply -f manifests/frontend-configmap.yaml
kubectl apply -f manifests/backend-configmap.yaml
kubectl apply -f manifests/backend-secret.yaml
kubectl apply -f manifests/db-secret.yaml

# RBAC before backend deployment
kubectl apply -f manifests/backend-serviceaccount.yaml
kubectl apply -f manifests/backend-role.yaml
kubectl apply -f manifests/backend-rolebinding.yaml

# Headless service before StatefulSet
kubectl apply -f manifests/db-headless-service.yaml

# All deployments and StatefulSet
kubectl apply -f manifests/frontend-deployment.yaml
kubectl apply -f manifests/backend-deployment.yaml
kubectl apply -f manifests/db-statefulset.yaml

# Services
kubectl apply -f manifests/frontend-service.yaml
kubectl apply -f manifests/backend-service.yaml

# Scaling and availability
kubectl apply -f manifests/frontend-hpa.yaml
kubectl apply -f manifests/frontend-pdb.yaml

# Ingress (requires ingress-nginx from lab 08)
kubectl apply -f manifests/ingress.yaml

# NetworkPolicy (enforced only with Calico — see lab 09)
kubectl apply -f manifests/networkpolicy.yaml
```

Wait for everything to reach Ready:

```bash
kubectl get all -n capstone
kubectl get pvc -n capstone
kubectl get ingress -n capstone
```

> How many pods are running? Are all three tiers healthy?

---

### 1.2 Verify the deployment

```bash
kubectl get pods -n capstone -o wide
kubectl get pdb -n capstone
kubectl get hpa -n capstone
```

> Which nodes are the pods on? Are the HPA targets visible?

---

## Phase 2: Verify service discovery

### 2.1 Test frontend → backend connectivity

```bash
FRONTEND_POD=$(kubectl get pod -n capstone -l app=frontend -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $FRONTEND_POD -n capstone -- wget -qO- http://backend-svc
```

> Does the frontend pod reach the backend service? What does it return?

```bash
kubectl exec -it $FRONTEND_POD -n capstone -- \
  wget -qO- http://backend-svc.capstone.svc.cluster.local
```

> Does the FQDN also work?

---

### 2.2 Test database per-pod DNS

```bash
kubectl exec -it $FRONTEND_POD -n capstone -- \
  nslookup db-0.db-headless.capstone.svc.cluster.local
```

> What IP does the StatefulSet pod's DNS name resolve to?

```bash
kubectl get pod db-0 -n capstone -o wide
```

> Does the IP match?

---

### 2.3 Inspect environment variables injected from ConfigMap and Secret

```bash
BACKEND_POD=$(kubectl get pod -n capstone -l app=backend -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $BACKEND_POD -n capstone -- env | grep -E "APP_ENV|SERVICE_NAME|API_KEY"
```

> Are the ConfigMap and Secret values present? Is the API_KEY from the Secret visible?

---

## Phase 3: Verify RBAC

### 3.1 Check what backend-sa can do

```bash
kubectl auth can-i list configmaps -n capstone \
  --as=system:serviceaccount:capstone:backend-sa

kubectl auth can-i list pods -n capstone \
  --as=system:serviceaccount:capstone:backend-sa

kubectl auth can-i delete deployments -n capstone \
  --as=system:serviceaccount:capstone:backend-sa

kubectl auth can-i list configmaps -n default \
  --as=system:serviceaccount:capstone:backend-sa
```

> Fill in your answers: yes/no for each. Does the ServiceAccount have access outside the capstone namespace?

---

### 3.2 Verify from inside the backend pod

```bash
kubectl exec -it $BACKEND_POD -n capstone -- \
  cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
```

> What ServiceAccount namespace is mounted in the backend pod?

---

## Phase 4: Scaling and availability

### 4.1 Check HPA status

```bash
kubectl get hpa frontend-hpa -n capstone
kubectl describe hpa frontend-hpa -n capstone
```

> What is the current replica count? What is the CPU utilization shown?

If metrics-server is installed (lab 14):

```bash
kubectl top pods -n capstone
```

### 4.2 Generate load to trigger HPA (optional)

```bash
# Open a second terminal — run this to generate load
kubectl run load-generator --image=busybox:stable --rm -it \
  --restart=Never -- \
  sh -c "while true; do wget -qO- http://frontend-svc.capstone; done"
```

In the first terminal, watch HPA:

```bash
kubectl get hpa frontend-hpa -n capstone -w
```

> How long until the HPA scales up? What replica count does it reach?

Stop the load generator (Ctrl+C in the second terminal).

```bash
# Watch it scale back down (takes 5 minutes by default)
kubectl get hpa frontend-hpa -n capstone -w
```

### 4.3 Check PDB protects the frontend

```bash
kubectl get pdb frontend-pdb -n capstone
```

> With 3 replicas and minAvailable: 2, what is ALLOWED DISRUPTIONS?

---

## Phase 5: Rolling update and rollback

### 5.1 Update the backend image

```bash
kubectl set image deployment/backend nginx=nginx:1.25 -n capstone
kubectl rollout status deployment/backend -n capstone
```

> How does the rolling update proceed with 2 replicas and no explicit maxUnavailable set?

```bash
kubectl rollout history deployment/backend -n capstone
```

### 5.2 Roll back to nginx:stable

```bash
kubectl rollout undo deployment/backend -n capstone
kubectl rollout status deployment/backend -n capstone
kubectl get pods -n capstone -l app=backend -o jsonpath='{.items[*].spec.containers[0].image}'
```

> Confirm the image is back to nginx:stable.

---

## Phase 6: Node maintenance with PDB

### 6.1 Drain kind-worker

```bash
kubectl drain kind-worker --ignore-daemonsets --delete-emptydir-data
```

> Does the drain succeed? Why does the PDB allow it? (3 replicas, minAvailable: 2 → 1 disruption allowed)

```bash
kubectl get pods -n capstone -o wide
```

> Where are all the capstone pods running now?

### 6.2 Restore

```bash
kubectl uncordon kind-worker
kubectl get nodes
```

---

## Phase 7: Kustomize overlays

### 7.1 Preview the overlays

```bash
kubectl kustomize kustomize/overlays/dev
kubectl kustomize kustomize/overlays/prod
```

> How do the dev and prod deployments differ in replica count and image tag?

### 7.2 Deploy dev and prod

```bash
kubectl create namespace capstone-dev
kubectl create namespace capstone-prod

kubectl apply -k kustomize/overlays/dev
kubectl apply -k kustomize/overlays/prod
```

```bash
kubectl get deploy -n capstone-dev
kubectl get deploy -n capstone-prod
```

> What are the deployment names (including namePrefix)? How many replicas each?

---

## Phase 8: Troubleshooting scenario

Apply this broken component:

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-frontend
  namespace: capstone
spec:
  replicas: 2
  selector:
    matchLabels:
      app: broken-frontend
  template:
    metadata:
      labels:
        app: broken-frontend
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        env:
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: db-creds-v2
              key: DB_PASS
EOF
```

```bash
kubectl get pods -n capstone -l app=broken-frontend
```

> What state are the pods in? Diagnose and fix the issue.

---

## Phase 9: etcd backup

```bash
ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd \
  -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl snapshot save /tmp/capstone-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl snapshot status /tmp/capstone-backup.db --write-out=table
```

> Record: revision number, total keys, database size.

---

## Phase 10: Final audit

```bash
# Count all resources in the capstone namespace
kubectl get all,pvc,cm,secret,sa,role,rolebinding,netpol,ingress,hpa,pdb -n capstone

# Verify all pods are Running/Ready
kubectl get pods -n capstone --field-selector=status.phase!=Running

# Check events for any warnings
kubectl get events -n capstone --sort-by=.metadata.creationTimestamp | tail -20
```

> Are there any pods not in Running state? Any unexpected events?
