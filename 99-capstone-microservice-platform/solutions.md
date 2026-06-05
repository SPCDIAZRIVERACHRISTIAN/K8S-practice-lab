# Solutions — 99 Capstone: Microservice Platform

---

## Phase 1: Deployment order

**Why headless Service before StatefulSet:**

When a StatefulSet pod starts, it immediately tries to register its DNS name (`db-0.db-headless.capstone.svc.cluster.local`). This requires the headless Service to already exist. If you create the StatefulSet first, the pods will still start, but their DNS registration may be delayed or incomplete until the Service is created.

**Why RBAC before the backend Deployment:**

When a pod starts, Kubernetes mounts the ServiceAccount's token. If the ServiceAccount does not exist, the pod cannot start (`Error: secrets "backend-sa-token-xxx" not found`). More importantly, the Role and RoleBinding must exist before the application inside the pod attempts to use the token — while mounting doesn't fail without the Role, any API call the application makes will be denied until the RoleBinding is in place.

**GitOps deployment order:**

In a GitOps pipeline (ArgoCD, Flux), dependency ordering is handled by sync waves or resource hooks. Resources with `argocd.argoproj.io/sync-wave: "-1"` (Namespaces, RBAC) are applied before wave 0 (deployments). Without sync waves, the reconciler applies all resources and retries failed ones until dependencies are available.

---

## Phase 2: Service discovery reference

**Three DNS forms for frontend → backend:**

```
http://backend-svc                                    # short name (same namespace only)
http://backend-svc.capstone                           # service.namespace form
http://backend-svc.capstone.svc.cluster.local         # FQDN — most explicit, portable
```

The FQDN is recommended in multi-namespace architectures and Ingress configurations because it works regardless of which namespace makes the request.

**db-0 DNS name:**

```
db-0.db-headless.capstone.svc.cluster.local
```

Format: `<pod-name>.<headless-service-name>.<namespace>.svc.cluster.local`

A Deployment pod gets a random name and a ClusterIP Service address — you cannot address a specific replica. A StatefulSet pod gets a stable ordinal name and its own DNS entry via the headless Service, enabling direct per-pod addressing. This is essential for databases where you need to reach the primary vs a replica.

---

## Phase 3: RBAC expected results

| Permission | Result | Reason |
|-----------|---------|--------|
| list configmaps in capstone | yes | Granted by backend-role |
| list pods in capstone | yes | Granted by backend-role |
| delete deployments in capstone | no | Deployments require apiGroup "apps", not granted |
| list configmaps in default | no | Role is namespace-scoped to capstone |

**Fix for the broken-frontend troubleshooting scenario:**

The broken-frontend deployment references Secret `db-creds-v2` which does not exist. Pods will fail with `CreateContainerConfigError`. Fix options:

```bash
# Option A: Create the missing secret
kubectl create secret generic db-creds-v2 \
  --from-literal=DB_PASS=placeholder \
  -n capstone

# Option B: Fix the deployment to reference the existing secret
kubectl patch deployment broken-frontend -n capstone \
  --type=json \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/env/0/valueFrom/secretKeyRef/name","value":"db-creds"}]'

# Option C: Delete the broken deployment
kubectl delete deployment broken-frontend -n capstone
```

The diagnostic command that first reveals the problem:
```bash
kubectl describe pod -n capstone -l app=broken-frontend | grep -A 10 Events
```
Output shows: `Error: secret "db-creds-v2" not found`

---

## Phase 4: HPA behavior

The HPA uses CPU utilization averaged across all frontend pods. When no load is running, CPU utilization is near 0% — well below the 50% target. The HPA will attempt to scale down to `minReplicas: 2` after the scale-down stabilization window (5 minutes by default).

During load generation with a busybox wget loop, CPU will spike on whichever pod handles requests. The HPA checks metrics every 15 seconds (configurable) and scales up when the average exceeds 50%. The HPA scale-down delay prevents oscillation — even after load stops, it waits 5 minutes before reducing replicas.

**PDB math:**
```
Current replicas = 3
minAvailable = 2
ALLOWED DISRUPTIONS = 3 - 2 = 1
```

One pod can be disrupted (evicted during drain, killed during rolling update) while maintaining availability.

---

## Phase 5: Rolling update with 2 replicas

With `replicas: 2` and default `maxUnavailable: 25%` (rounds down to 0) and `maxSurge: 25%` (rounds up to 1):
- Kubernetes brings up 1 new pod (now 3 total: 2 old, 1 new)
- When the new pod is Ready, it terminates 1 old pod (now 2: 1 old, 1 new)
- Brings up another new pod (3 total)
- When Ready, terminates the last old pod
- Final state: 2 new pods

The service always has at least one ready pod during this process. The backend is never fully unavailable.

**Post-rollback revision:** The rollback creates a new revision (e.g., revision 3 if you had installed at 1, upgraded to 2). Helm and Kubernetes both increment revisions on rollback rather than going backwards.

---

## Phase 6: Drain with PDB

The drain of `kind-worker` succeeds because:
- `frontend-pdb` requires `minAvailable: 2`
- With 3 running pods, ALLOWED DISRUPTIONS = 1
- The drain evicts one pod at a time
- After each eviction, the scheduler starts a replacement on `kind-worker2`
- Once the replacement is Ready, the next pod can be evicted

If the HPA had scaled frontend down to exactly 2 replicas before the drain, the drain would block — ALLOWED DISRUPTIONS would be 0.

**Note on DaemonSet pods:** If `node-monitor` from lab 24 is running, use `--ignore-daemonsets`. The DaemonSet pods stay on the node but won't run any new scheduled workloads.

---

## Phase 7: Kustomize overlay outputs

Dev overlay result:
- Deployment name: `dev-backend` (namePrefix `dev-` + base name `backend`)
- Service name: `dev-backend`
- Namespace: `capstone-dev`
- Image: `nginx:1.25`
- Replicas: 1
- Labels: `managed-by: kustomize`, `env: dev`

Prod overlay result:
- Deployment name: `prod-backend`
- Service name: `prod-backend`
- Namespace: `capstone-prod`
- Image: `nginx:stable`
- Replicas: 3
- Labels: `managed-by: kustomize`, `env: prod`

---

## Phase 9: etcd backup command reference

```bash
ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd \
  -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl snapshot save /tmp/capstone-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

The revision number after completing this capstone lab will be much higher than in lab 23 because you have created hundreds of objects across all the labs. Each create/update/delete operation increments the etcd revision counter.

---

## What production additions would look like

**1. TLS on the Ingress:**
```yaml
spec:
  tls:
  - hosts: [capstone.example.com]
    secretName: capstone-tls
```
With cert-manager providing automatic certificate rotation from Let's Encrypt.

**2. Horizontal scaling with KEDA instead of HPA:**
KEDA can scale on custom metrics (queue depth, request rate) rather than just CPU, enabling more intelligent scaling for the backend and database tiers.

**3. Separate namespace per tier with cross-namespace NetworkPolicy:**
Isolating frontend, backend, and database into separate namespaces with cross-namespace NetworkPolicy selectors provides stronger security isolation — a compromise of the frontend namespace cannot directly reach the database namespace.

**4. Secret management with external-secrets-operator:**
Storing `API_KEY` and `DB_PASS` in Kubernetes Secrets is convenient but means secrets live in etcd (encrypted at rest if configured, but still accessible to anyone with etcd access or cluster-admin). In production, use External Secrets Operator to pull secrets from Vault, AWS Secrets Manager, or GCP Secret Manager.

**5. Observability:**
Add Prometheus ServiceMonitor annotations, centralized logging (Loki or EFK stack), and distributed tracing (Jaeger). The capstone has no observability tooling — this is intentional, as it's covered in Phase 7 labs.
