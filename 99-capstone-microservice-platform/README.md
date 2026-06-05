# Lab 99 — Capstone: Microservice Platform

## Goal

Deploy and operate a complete multi-tier microservice platform from scratch. This lab combines every major CKA domain: workloads, networking, storage, RBAC, configuration management, scaling, and troubleshooting. It is a demo-quality deployment usable as a final review and portfolio piece.

## Architecture

```
Internet
  ↓ (port 80)
Ingress (capstone-ingress)
  ├─→ / ──────────────────→ frontend-svc → frontend pods (3 replicas, HPA 2–6)
  └─→ /api ───────────────→ backend-svc  → backend pods  (2 replicas)
                                               ↓
                                         db-headless → db-0 (StatefulSet, PVC)
```

NetworkPolicy (requires CNI with enforcement — see lab 09):
- default-deny: all ingress blocked
- allow-frontend-ingress: external → frontend:80
- allow-backend-from-frontend: frontend → backend:80
- allow-db-from-backend: backend → db:80

## Teaches

- End-to-end Kubernetes deployment: dependency ordering, multi-tier services
- ConfigMap and Secret injection (envFrom and secretRef)
- RBAC: ServiceAccount → Role → RoleBinding (backend reads ConfigMaps)
- StatefulSet with PVC and headless Service
- HPA + PDB on the frontend tier
- Ingress routing (requires ingress-nginx from lab 08)
- NetworkPolicy design for a three-tier app
- Rolling updates and rollback on a live deployment
- Node maintenance during live operation (drain, reschedule, uncordon)
- Kustomize for environment-specific backend deployment (dev/prod overlays)
- etcd backup as the final administrative task

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`)
- Lab 08 completed: ingress-nginx installed (for Ingress to work)
- Lab 14 completed: metrics-server installed (for HPA to work)
- Helm installed (for optional section)

## What You Will Build

| Resource | Name | Purpose |
|----------|------|---------|
| Namespace | capstone | Isolates all platform resources |
| ConfigMap | frontend-config | Env vars injected into frontend pods |
| Deployment | frontend | nginx, 3 replicas, probes, limits |
| Service | frontend-svc | ClusterIP, port 80 |
| HPA | frontend-hpa | Auto-scales frontend 2–6 replicas |
| PDB | frontend-pdb | Ensures at least 2 frontend pods during maintenance |
| ConfigMap | backend-config | Env vars for backend |
| Secret | backend-secret | API keys for backend |
| ServiceAccount | backend-sa | Identity for backend pods |
| Role + RoleBinding | backend-role | Grants backend-sa read access to ConfigMaps/Pods |
| Deployment | backend | nginx, 2 replicas, uses backend-sa |
| Service | backend-svc | ClusterIP, port 80 |
| Secret | db-creds | DB credentials |
| Service (headless) | db-headless | Per-pod DNS for StatefulSet |
| StatefulSet | db | 1 replica, PVC 100Mi |
| NetworkPolicy (×4) | — | Three-tier isolation |
| Ingress | capstone-ingress | Routes / and /api to respective services |
| Kustomize | base + dev/prod overlays | Environment-specific backend deployment |

## Files

```
manifests/
  namespace.yaml
  frontend-configmap.yaml
  frontend-deployment.yaml
  frontend-service.yaml
  frontend-hpa.yaml
  frontend-pdb.yaml
  backend-configmap.yaml
  backend-secret.yaml
  backend-serviceaccount.yaml
  backend-role.yaml
  backend-rolebinding.yaml
  backend-deployment.yaml
  backend-service.yaml
  db-secret.yaml
  db-headless-service.yaml
  db-statefulset.yaml
  networkpolicy.yaml
  ingress.yaml

kustomize/
  base/
    deployment.yaml, service.yaml, kustomization.yaml
  overlays/
    dev/kustomization.yaml
    prod/kustomization.yaml
```

## Success Criteria

- All pods in `capstone` namespace reach Running/Ready
- `kubectl exec` into a frontend pod: `wget -qO- http://backend-svc` returns a response
- `kubectl auth can-i list configmaps -n capstone --as=system:serviceaccount:capstone:backend-sa` → yes
- `kubectl auth can-i delete deployments -n capstone --as=system:serviceaccount:capstone:backend-sa` → no
- HPA shows targets after generating load
- Rolling update of backend completes with zero downtime (2 replicas, 1 always available during update)
- Drain of `kind-worker` succeeds (PDB allows it since frontend has 3 pods, minAvailable 2)
- Kustomize dev overlay deploys to `capstone-dev` with 1 replica nginx:1.25
- Kustomize prod overlay deploys to `capstone-prod` with 3 replicas nginx:stable
- etcd snapshot saved and verified

## Difficulty

Capstone — assumes completion of all prior labs. No step-by-step guidance in commands.md beyond the task list.
