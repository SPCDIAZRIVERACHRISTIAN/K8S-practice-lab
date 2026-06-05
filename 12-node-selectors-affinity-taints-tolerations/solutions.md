# Solutions — 12 Node Selectors, Affinity, Taints, and Tolerations

---

## nodeSelector

`nodeSelector` is the simplest scheduling constraint. The pod will only be scheduled on a node that has all the key-value pairs listed under `nodeSelector` in its labels.

If no node has the required label, the pod stays Pending indefinitely with an event like:
```
0/3 nodes are available: 1 node(s) had untolerated taint, 2 node(s) didn't match Pod's node affinity/selector.
```

The moment you add the label to a node, the scheduler reconsiders the pod and places it.

---

## Node affinity

Node affinity is a more expressive version of nodeSelector. It uses `matchExpressions` which support operators: `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`.

Two types:

| Type | Behavior |
|------|----------|
| `requiredDuringSchedulingIgnoredDuringExecution` | Hard requirement. Pod stays Pending if no node matches. Same as nodeSelector. |
| `preferredDuringSchedulingIgnoredDuringExecution` | Soft preference. Scheduler tries to find a matching node but will schedule elsewhere if none is available. |

`IgnoredDuringExecution` means: if the node's labels change AFTER a pod is already running there, Kubernetes does NOT evict the pod. A future `RequiredDuringExecution` type (not yet stable) would evict it.

---

## Taints and tolerations

A taint is applied to a **node**. It says: "repel pods that do not explicitly tolerate me."

A toleration is applied to a **pod**. It says: "I am willing to be scheduled on a node with this taint."

Three taint effects:

| Effect | Behavior |
|--------|----------|
| `NoSchedule` | Pods without a matching toleration will NOT be scheduled on this node. Running pods are not affected. |
| `PreferNoSchedule` | Pods without a matching toleration will try to avoid this node, but may land here if no other node is available. |
| `NoExecute` | Pods without a matching toleration will NOT be scheduled here AND any currently running pods without the toleration will be evicted. |

**A toleration does not force a pod to a node — it just permits it.** If you want to force a pod to a specific tainted node, combine a toleration (to allow it past the taint) with a nodeSelector or affinity (to require that specific node).

---

## The control-plane taint

```
node-role.kubernetes.io/control-plane:NoSchedule
```

This taint is automatically applied to control-plane nodes. It prevents user workloads from being scheduled there by default, reserving control-plane resources for the Kubernetes components.

Pods that need to run on control-plane nodes (like some DaemonSets in kube-system) have a matching toleration:
```yaml
tolerations:
- key: node-role.kubernetes.io/control-plane
  effect: NoSchedule
```

---

## Taint vs nodeSelector semantics

| | nodeSelector / affinity | Taint + toleration |
|--|------------------------|-------------------|
| Direction | Pod says "I want to go HERE" | Node says "Only pods that agree can come HERE" |
| Use case | Pod-specific requirements (needs SSD, GPU, specific zone) | Node-level restrictions (dedicated nodes, special hardware, maintenance) |
| Default behavior | No effect if not set | All pods can schedule on untainted nodes |

Use taints when you want to reserve nodes for specific workloads (e.g., GPU nodes, logging agents). Use node affinity when a workload has a preference or requirement for a node type.

---

## Common mistakes

**Forgetting to remove taints after the lab**
Taints persist on nodes across pod deletions and namespace cleanups. Always remove taints explicitly when done.

**Confusing toleration with affinity**
A toleration says "I can go there if scheduled there." Affinity says "I want to go there." They serve different purposes and are often used together.

**nodeSelector vs requiredDuringScheduling affinity**
They are functionally equivalent, but node affinity supports richer expressions (`In`, `Gt`, etc.) and can be combined with soft preferences in the same spec. For simple key-value matching, nodeSelector is fine. For anything more complex, use affinity.
