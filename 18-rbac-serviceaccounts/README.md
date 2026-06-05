# Lab 18 — RBAC & ServiceAccounts

## Goal

Understand how Kubernetes authorizes access to the API server using Role-Based Access Control. Build a ServiceAccount with least-privilege permissions, verify what it can and cannot do, and fix a broken RBAC configuration.

## Teaches

- What a ServiceAccount is and why pods use them
- Role vs ClusterRole — namespace-scoped vs cluster-scoped permissions
- RoleBinding vs ClusterRoleBinding
- How to write RBAC rules (apiGroups, resources, verbs)
- `kubectl auth can-i` — the fastest way to audit permissions
- Impersonation: `--as=system:serviceaccount:<namespace>:<name>`
- Least-privilege principle in practice
- Common RBAC mistakes: wrong subject name, empty rules, missing namespace scope

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`)
- Comfortable with namespaces (Lab 10)

## What You Will Build

A namespace `lab-18-rbac` containing:
- A Deployment (`sample-app`) with 2 nginx pods
- A ServiceAccount (`lab-reader`) that can **list and get pods** but **cannot delete or modify deployments**
- A Role (`pod-reader`) with minimal permissions
- A RoleBinding connecting the Role to the ServiceAccount
- A test pod (`rbac-tester`) running as `lab-reader` to prove the permissions

You will then use `kubectl auth can-i` with impersonation to audit permissions without needing to exec into a pod.

## Files

```
manifests/
  namespace.yaml          — lab-18-rbac namespace
  serviceaccount.yaml     — lab-reader ServiceAccount
  role.yaml               — pod-reader Role (list/get pods only)
  rolebinding.yaml        — binds pod-reader to lab-reader
  target-deployment.yaml  — sample-app deployment (the thing you cannot delete)
  test-pod.yaml           — rbac-tester pod running as lab-reader

broken/
  role-empty.yaml         — Role with no rules (everything denied)
  rolebinding-wrong-sa.yaml — RoleBinding pointing at nonexistent ServiceAccount
```

## Success Criteria

- `kubectl auth can-i list pods -n lab-18-rbac --as=system:serviceaccount:lab-18-rbac:lab-reader` returns **yes**
- `kubectl auth can-i delete deployments -n lab-18-rbac --as=system:serviceaccount:lab-18-rbac:lab-reader` returns **no**
- `kubectl auth can-i list pods -n default --as=system:serviceaccount:lab-18-rbac:lab-reader` returns **no** (Role is namespace-scoped)
- Exec into `rbac-tester`, run `kubectl get pods` — succeeds
- Exec into `rbac-tester`, run `kubectl delete deployment sample-app` — returns a Forbidden error
- After applying broken Role: `kubectl auth can-i list pods` returns **no** for the ServiceAccount
- After fixing the Role: permissions are restored

## Difficulty

Medium — RBAC is conceptually straightforward but the subject format and namespace scoping trip up most people on the CKA.
