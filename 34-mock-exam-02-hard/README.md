# Lab 34 — mock-exam-02-hard

## Goal

Harder CKA-style mock exam. 15 tasks. 2-hour time limit. More troubleshooting-heavy than Exam 01, with higher difficulty weighting per task.

Work through the tasks in order. Do not consult `solutions.md` until you have finished or time has expired. Use official Kubernetes documentation at [kubernetes.io](https://kubernetes.io) if needed — it is allowed on the real CKA exam.

**Total points:** 62

---

## Exam Rules

- Time limit: **2 hours**
- Allowed resource: [kubernetes.io](https://kubernetes.io) documentation only
- No solutions.md, no hints, no outside resources
- Complete tasks in order; move on if stuck — return at the end if time permits

---

## Scoring Guide

| Score | Readiness |
|-------|-----------|
| 58–62 | Exam-ready |
| 48–57 | Almost ready — review weak areas |
| 37–47 | More practice needed |
| < 37 | Revisit core concepts |

---

## Teaches

- Static pod identification
- Diagnosing CrashLoopBackOff with ConfigMap volume mounts
- Liveness probe troubleshooting
- PodDisruptionBudgets and draining nodes
- ClusterRoles and ClusterRoleBindings for cluster-scoped resources
- PVC troubleshooting (wrong StorageClass)
- StatefulSet with headless service and per-pod DNS
- Node affinity
- etcd snapshot inspection
- Certificate expiration checking
- Multi-tier NetworkPolicy
- CronJob and manual Job creation
- Diagnosing Pending pods
- Kustomize overlays
- Service selector troubleshooting

---

## Prerequisites

- Running kind cluster with nodes: `kind-control-plane`, `kind-worker`, `kind-worker2`
- `kubectl` configured and pointing at the cluster
- `etcdctl` available (or accessible via exec into the control-plane container)
- `kubectl kustomize` or `kustomize` CLI available

---

## Files

| File | Purpose |
|------|---------|
| `exam.md` | The 15 exam tasks — open this and start your timer |
| `solutions.md` | Complete solutions — only open after finishing |
| `notes.md` | Post-exam workbook |
| `cleanup.sh` | Tear down all resources created in this exam |

---

## Difficulty

**Very Hard** — Full CKA simulation with advanced troubleshooting, Kustomize, PDB, and cluster-level tasks.
