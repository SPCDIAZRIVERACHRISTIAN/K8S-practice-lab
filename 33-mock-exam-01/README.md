# Lab 33 — mock-exam-01

## Goal

Full CKA-style mock exam. 17 tasks. 2-hour time limit.

Work through the tasks in order. Do not consult `solutions.md` until you have finished or time has expired. Use official Kubernetes documentation at [kubernetes.io](https://kubernetes.io) if needed — it is allowed on the real CKA exam.

**Total points:** 65

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
| 60–65 | Exam-ready |
| 50–59 | Almost ready — review weak areas |
| 40–49 | More practice needed |
| < 40 | Revisit core concepts |

---

## Teaches

- Full spectrum of CKA exam domains under time pressure:
  - Workloads (pods, deployments, rollouts)
  - Services and networking (NodePort, NetworkPolicy)
  - Storage (PVCs, volume mounts)
  - Configuration (ConfigMaps, Secrets, envFrom)
  - RBAC (Roles, RoleBindings, ServiceAccounts, auth can-i)
  - Cluster maintenance (cordon, drain, taints, tolerations)
  - StatefulSets and headless services
  - etcd backup
  - Troubleshooting

---

## Prerequisites

- Running kind cluster with nodes: `kind-control-plane`, `kind-worker`, `kind-worker2`
- `kubectl` configured and pointing at the cluster
- `etcdctl` available (or accessible via exec into the control-plane container)

---

## Files

| File | Purpose |
|------|---------|
| `exam.md` | The 17 exam tasks — open this and start your timer |
| `solutions.md` | Complete solutions — only open after finishing |
| `notes.md` | Post-exam workbook |
| `cleanup.sh` | Tear down all resources created in this exam |

---

## Difficulty

**Hard** — Full CKA exam simulation.
