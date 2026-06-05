# Lab 23 — etcd Backup & Restore Concept Lab

## Goal

Understand etcd's role as Kubernetes' single source of truth, learn how to take and verify an etcd snapshot, and understand the full backup/restore procedure used in production — and on the CKA exam.

## Teaches

- What etcd stores and why it is the most critical component to back up
- `etcdctl` — the etcd command-line client
- `etcdctl snapshot save` — taking a snapshot
- `etcdctl snapshot status` — verifying a snapshot
- `etcdctl snapshot restore` — the restore procedure (conceptual + command reference)
- The etcd TLS cert flags required for every `etcdctl` command
- How to find the etcd pod, endpoints, and cert paths in a running cluster
- What `ETCDCTL_API=3` means and why it matters
- The CKA backup/restore procedure step-by-step

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`)
- Lab 22 completed (you know where etcd lives and its cert paths)

## What You Will Do

1. Create objects in a test namespace — these become the "state to protect"
2. Inspect etcd: member list, endpoint health, endpoint status
3. Take a snapshot using the provided script or step-by-step commands
4. Verify the snapshot with `etcdctl snapshot status`
5. Copy the snapshot out of the pod to the host filesystem
6. Walk through the restore procedure conceptually (commands provided — **do not run restore in this cluster**)
7. Understand why restore is destructive and what precautions production requires

## Files

```
manifests/
  namespace.yaml          — lab-23-etcd namespace
  test-configmap.yaml     — marker object to confirm what's in the cluster
  test-secret.yaml        — demonstrates that secrets are in etcd

scripts/
  backup-etcd.sh          — automated backup script (exec + copy)
```

## Safety Note

**Do not run `etcdctl snapshot restore` in your kind cluster.**

The restore procedure:
1. Stops the API server (by moving its static pod manifest)
2. Replaces etcd's data directory with the snapshot
3. Restarts the API server

Running this in a live cluster is intentionally destructive — it replaces current state with the snapshot state. The commands are documented in `solutions.md` for study. Run them only in a dedicated restore test environment.

## Success Criteria

- `etcdctl member list` returns the etcd cluster member(s)
- `etcdctl endpoint health` shows etcd as healthy
- `etcdctl snapshot save` completes without error
- `etcdctl snapshot status` shows revision count and database size
- The snapshot file is copied to the host filesystem (`etcd-snapshot.db`)
- You can write out the full restore command sequence from memory (open-book is fine)
- You can explain why the API server must be stopped before etcd is restored

## Difficulty

Hard — the concepts are approachable, but the cert flags, API version env variable, and exact command syntax are all tested on the CKA. Precision matters.
