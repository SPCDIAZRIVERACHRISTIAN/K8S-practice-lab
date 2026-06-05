# Lab 24 — Upgrades & Node Maintenance

## Goal

Learn how to safely take a Kubernetes node out of service for maintenance (patching, rebooting, upgrading), observe how workloads are rescheduled, and understand how PodDisruptionBudgets protect application availability during maintenance windows.

## Teaches

- `kubectl cordon` — marks a node unschedulable (new pods will not be placed there)
- `kubectl drain` — evicts existing pods from a node, then cordons it
- `kubectl uncordon` — restores a node to schedulable state after maintenance
- `kubectl taint` — adding and removing node taints manually
- Node conditions: `Ready`, `SchedulingDisabled`, `MemoryPressure`, `DiskPressure`
- `kubectl describe node` — reading node status, capacity, allocatable resources, pod list
- PodDisruptionBudget (PDB): `minAvailable`, `maxUnavailable`
- How `kubectl drain` respects PDBs — blocking eviction when it would violate the budget
- `ALLOWED DISRUPTIONS` — the live field that tells you how many pods can currently be evicted
- DaemonSets during drain — why they require `--ignore-daemonsets`
- emptyDir during drain — why they require `--delete-emptydir-data`
- The kubeadm node upgrade procedure (conceptual + command reference)

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`) — requires worker nodes (`kind-worker`, `kind-worker2`)
- Lab 13 (DaemonSets) recommended but not required

## What You Will Build

A deployment (`webapp`) with 4 replicas and a DaemonSet (`node-monitor`) running in `lab-24-maintenance`. You will:

1. Cordon a worker node and observe that new pods avoid it
2. Drain the node and watch pods reschedule onto the remaining worker
3. Uncordon the node and watch pods rebalance
4. Apply a PDB that blocks drain — observe the error and the ALLOWED DISRUPTIONS counter
5. Resolve the PDB conflict and complete the drain

## Files

```
manifests/
  namespace.yaml      — lab-24-maintenance namespace
  deployment.yaml     — webapp: 4 replicas, nginx:stable
  pdb.yaml            — webapp-pdb: minAvailable=3 (intentionally tight to trigger PDB conflict)
  daemonset.yaml      — node-monitor: runs on every node including control-plane
```

## Success Criteria

- `kubectl get nodes` shows `kind-worker` as `SchedulingDisabled` after cordon
- New pods scheduled after cordon land only on `kind-worker2`
- `kubectl drain` evicts all non-DaemonSet pods from `kind-worker` and all pods move to `kind-worker2`
- After uncordon, new pods can be scheduled on `kind-worker` again
- `kubectl get pdb -n lab-24-maintenance` shows `ALLOWED DISRUPTIONS: 0` when 4 replicas are running with `minAvailable: 3` and you try to drain a node that has only 1 extra replica
- Drain blocks with the expected PDB error message
- You can explain the three options for resolving a PDB conflict

## Difficulty

Hard — the individual commands are simple, but understanding the PDB math and knowing the exact drain flags for DaemonSets and emptyDir is tested precisely on the CKA.
