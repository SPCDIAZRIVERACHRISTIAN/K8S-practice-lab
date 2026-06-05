# Lab 28 — Troubleshoot Storage

## Goal

Diagnose and fix four common persistent storage failures in Kubernetes: wrong StorageClass, wrong access mode, missing PVC, and an immutable StatefulSet volumeClaimTemplate.

## Teaches

- Reading PVC status: `Pending` → why, what to look at
- `kubectl describe pvc` — reading the Events section for provisioner errors
- StorageClass mismatch: no provisioner responds to an unknown class
- Access mode mismatch: `ReadWriteMany` vs `ReadWriteOnce` limitations of local storage
- `ContainerCreating` on a pod with a missing PVC reference
- Why StatefulSet `volumeClaimTemplates` is immutable — and what to do about it
- `kubectl get storageclass` — finding available provisioners

## Prerequisites

- Lab 00 cluster running
- Lab 16 (PV, PVC, StorageClass) completed

## What You Will Do

Apply four broken storage configurations, diagnose each using `kubectl describe`, and fix them without deleting and reapplying the whole namespace unless necessary.

## Files

```
manifests/
  namespace.yaml                 — lab-28-storage

broken/
  01-wrong-storageclass.yaml     — PVC referencing nonexistent StorageClass → Pending
  02-wrong-accessmode.yaml       — PVC with ReadWriteMany on local storage → Pending
  03-pod-missing-pvc.yaml        — Pod referencing nonexistent PVC → ContainerCreating
  04-statefulset-bad-sc.yaml     — StatefulSet with bad SC in volumeClaimTemplates → Pending
```

## Success Criteria

- All four PVCs eventually reach `Bound` after fixes
- `pod-missing-pvc` transitions from `ContainerCreating` to `Running`
- StatefulSet `broken-db` has all replicas Running after recreation
- You can explain why StatefulSet volumeClaimTemplates cannot be patched in place

## Difficulty

Hard — understanding why each fix works requires knowing how StorageClass provisioning, access modes, and StatefulSet immutability work under the hood.
