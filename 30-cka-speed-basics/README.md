# Lab 30 — cka-speed-basics

## Goal

Practice creating Kubernetes objects **imperatively** at CKA exam speed. No manifest files — every task uses pure `kubectl` commands. The goal is to build muscle memory for the commands you need to recall under time pressure.

**Target:** Complete all 12 tasks in under 45 minutes total.

---

## Teaches

- Imperative `kubectl create`, `kubectl run`, `kubectl expose`, `kubectl scale`, `kubectl set image`
- Rollout history and rollback
- ConfigMaps and Secrets from literal values
- Injecting ConfigMap and Secret keys as environment variables
- ServiceAccounts, Roles, and RoleBindings from the command line
- Label selectors across namespaces
- Generating YAML with `--dry-run=client -o yaml`

---

## Prerequisites

- Running kind cluster with nodes: `kind-control-plane`, `kind-worker`, `kind-worker2`
- `kubectl` configured and pointing at the cluster

---

## What You Will Do

1. Create a namespace
2. Create a deployment imperatively
3. Expose a deployment as a ClusterIP service
4. Scale a deployment
5. Update a deployment image
6. Check rollout history and roll back
7. Create a ConfigMap from literal values
8. Create a Secret from literal values
9. Create a pod with environment variables from a ConfigMap and a Secret
10. Create a ServiceAccount and RoleBinding
11. List pods by label across all namespaces
12. Generate a pod YAML manifest without applying it

---

## Files

| File | Purpose |
|------|---------|
| `tasks.md` | Numbered timed tasks — work through these |
| `solutions.md` | Exact commands and CKA speed tips |
| `notes.md` | Workbook — fill in after completing tasks |
| `cleanup.sh` | Tear down all resources created in this lab |

---

## Success Criteria

- All 12 tasks completed correctly
- Total time under 45 minutes
- No YAML files written by hand — all objects created imperatively

---

## Difficulty

**Medium** — No YAML authoring required, but you must know the command flags by heart.
