# Lab 29 — Troubleshoot Cluster Nodes

## Goal

Diagnose and fix node-level scheduling failures using safe, reversible simulations. Learn to read scheduling failure messages in `kubectl describe pod`, identify the exact cause, and apply the minimum fix.

## Teaches

- Reading `Events` section for scheduling failures: taint, nodeSelector, affinity messages
- Taint/toleration troubleshooting: adding, matching, and removing taints
- nodeSelector: adding labels to nodes, removing labels
- Node affinity: required vs preferred, how to fix an impossible required rule
- `kubectl describe node` — reading conditions, taints, labels, allocatable resources
- The difference between "no nodes available" (nodeSelector/affinity) and "taint" failure messages
- How to use `kubectl get nodes --show-labels` to audit node labels
- Cordon vs taint: when to use each for scheduling control

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`)
- Lab 12 (node selectors, affinity, taints) completed

## What You Will Do

1. Apply a base deployment and observe normal pod scheduling
2. Add a custom taint to a node, then apply a pod without a toleration — observe Pending
3. Fix: add a toleration to the pod
4. Apply a pod with a nodeSelector for a nonexistent label — observe Pending
5. Fix: add the label to the node (or remove the nodeSelector)
6. Apply a pod with required node affinity for a nonexistent node — observe Pending
7. Fix: correct the affinity to an existing node

## Files

```
manifests/
  namespace.yaml         — lab-29-nodes
  deployment.yaml        — node-test: 3 replicas, no constraints

broken/
  01-no-toleration.yaml  — pod with no toleration (use with custom taint on node)
  02-bad-nodeselector.yaml — pod requiring label disktype=nvme-ultra (does not exist)
  03-bad-affinity.yaml   — pod with required affinity to nonexistent-node-xyz
```

## Success Criteria

- All three broken pods reach Running after the correct fix
- You can write the exact `kubectl describe pod` event message for each scheduling failure from memory
- Custom taint is removed from nodes after the lab
- No labels were left on nodes after cleanup

## Difficulty

Hard — recognizing scheduling failures quickly under exam pressure requires knowing the exact wording of each error message.
