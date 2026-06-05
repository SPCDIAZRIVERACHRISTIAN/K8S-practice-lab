# Lab 31 — cka-speed-networking-storage

## Goal

Timed drills covering Kubernetes networking and storage object creation. Build speed and confidence with services, DNS, PVCs, NetworkPolicies, and volumes.

**Target:** Complete all 10 tasks in under 60 minutes.

---

## Teaches

- Creating ClusterIP and NodePort services imperatively
- DNS resolution with `nslookup` inside the cluster
- PersistentVolumeClaims and volume mounts
- Writing to a mounted volume via `kubectl exec`
- NetworkPolicy for deny-all and allowlist rules
- Identifying the default StorageClass

---

## Prerequisites

- Running kind cluster with nodes: `kind-control-plane`, `kind-worker`, `kind-worker2`
- `kubectl` configured and pointing at the cluster
- Setup manifests applied (see below)

---

## Setup

Apply the setup manifests before starting the timed tasks:

```bash
kubectl apply -f setup/namespace.yaml
kubectl apply -f setup/backend-deployment.yaml
```

Wait for the deployment to be ready:

```bash
kubectl rollout status deployment/api -n speed-31
```

---

## What You Will Do

1. Create a ClusterIP service with a specific port mapping
2. Resolve a service DNS name from inside a temporary pod
3. Create a PVC imperatively
4. Create a pod that mounts a PVC
5. Write a file to a mounted volume
6. Create a deny-all NetworkPolicy
7. Create an allowlist NetworkPolicy
8. Create a NodePort service
9. List StorageClasses and identify the default
10. Test DNS for `kubernetes.default.svc.cluster.local`

---

## Files

| File | Purpose |
|------|---------|
| `setup/namespace.yaml` | Namespace for this lab |
| `setup/backend-deployment.yaml` | Deployment to use as a backend |
| `tasks.md` | Numbered timed tasks |
| `solutions.md` | Exact kubectl commands and NetworkPolicy YAML |
| `notes.md` | Workbook — fill in after completing tasks |
| `cleanup.sh` | Tear down all resources created in this lab |

---

## Success Criteria

- All 10 tasks completed correctly
- Total time under 60 minutes
- NetworkPolicy tasks require YAML — have the structure memorized

---

## Difficulty

**Medium-Hard** — NetworkPolicies cannot be created imperatively and require accurate YAML.
