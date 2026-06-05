# Solutions — 17 StatefulSets

---

## What problems StatefulSets solve

A Deployment creates pods with random names (e.g., `web-7d6f9b-xktz4`). When a pod is replaced, the new pod gets a new random name and a new IP. Any state stored locally is gone.

A StatefulSet provides:
1. **Stable pod identity** — `web-0`, `web-1`, `web-2`. The ordinal suffix is permanent for the lifetime of the StatefulSet.
2. **Stable network identity** — each pod gets a DNS name: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`
3. **Stable storage** — each pod has its own PVC that is not deleted when the pod is deleted

These three guarantees together make StatefulSets suitable for workloads that need to know who they are and remember what they stored.

---

## Ordered startup and shutdown

StatefulSet pods start in order: 0, 1, 2. Each pod must be `Running` and `Ready` before the next one starts. This matters for clustered applications (e.g., database replicas) where node 0 must be the primary before secondaries join.

Pods are deleted in reverse order: N-1, N-2, ..., 0. This ensures graceful leader handoff in leader-follower setups.

For applications that do not need ordered startup/shutdown, set `podManagementPolicy: Parallel` in the StatefulSet spec to start/stop pods simultaneously.

---

## volumeClaimTemplates

```yaml
volumeClaimTemplates:
- metadata:
    name: data
  spec:
    accessModes: [ReadWriteOnce]
    resources:
      requests:
        storage: 50Mi
    storageClassName: standard
```

This creates one PVC per pod, named: `<template-name>-<pod-name>`:
- `data-web-0`
- `data-web-1`
- `data-web-2`

**PVCs are NOT deleted when:**
- A pod is deleted and recreated (pod comes back, reattaches to same PVC)
- The StatefulSet is scaled down (PVCs for removed pods are retained)

**PVCs ARE deleted when:**
- The StatefulSet itself is deleted, IF you also manually delete the PVCs (they are not auto-deleted with the StatefulSet)
- You explicitly delete the PVC with `kubectl delete pvc`

This means if you scale down from 5 to 2 and then scale back up, pods web-2 through web-4 will reattach to their old PVCs and recover their data.

---

## Headless Service and per-pod DNS

A headless Service (`clusterIP: None`) does not provide a virtual IP. Instead:
- DNS queries for the Service return the IPs of all ready pods (round-robin DNS)
- DNS queries for a specific pod (`web-0.web`) return that pod's IP directly

Per-pod DNS format:
```
<pod-name>.<service-name>.<namespace>.svc.cluster.local
```

Example:
```
web-0.web.lab-17-statefulsets.svc.cluster.local → 10.244.1.5
web-1.web.lab-17-statefulsets.svc.cluster.local → 10.244.2.3
```

This lets other pods in the cluster address a specific StatefulSet member by name. A database client that needs to reach the primary can target `db-0.db` rather than an arbitrary pod.

---

## StatefulSet vs Deployment

| | StatefulSet | Deployment |
|--|-------------|------------|
| Pod names | Stable: web-0, web-1 | Random: web-7d6f9b-abc |
| Pod DNS | Per-pod stable DNS | Shared via Service |
| Storage | Per-pod PVC, survives pod deletion | Shared PVC or ephemeral |
| Startup order | Sequential (0, 1, 2) | Parallel |
| Use case | Databases, queues, distributed systems | Stateless web servers, APIs |

**Use StatefulSet for:** PostgreSQL, MySQL, MongoDB, Kafka, ZooKeeper, Redis clusters, Elasticsearch nodes — any workload where individual instances have identity or per-instance state.

**Use Deployment for:** nginx web servers, REST APIs, workers consuming from a shared queue — any workload where all instances are interchangeable.

---

## Common mistakes

**Forgetting to create the headless Service**
The StatefulSet's `serviceName` field must match an existing Service. If the Service does not exist, the StatefulSet's pods will still start but they will not have stable DNS names.

**Deleting a StatefulSet and expecting PVCs to be cleaned up**
`kubectl delete statefulset web` does NOT delete the PVCs. You must delete them separately. This is intentional — data protection. But it also means orphaned PVCs consume storage until manually cleaned up.

**Using a StatefulSet for a stateless app**
StatefulSets add complexity (ordered startup, PVC management, headless Service). If your application is stateless, use a Deployment.
