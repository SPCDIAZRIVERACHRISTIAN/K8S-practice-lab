# Solutions — 29 Troubleshoot Cluster Nodes

---

## Scheduling failure messages — reference table

| Cause | Exact event message |
|-------|-------------------|
| Taint without toleration | `N node(s) had untolerated taint {dedicated=gpu:NoSchedule}` |
| nodeSelector mismatch | `N node(s) didn't match Pod's node affinity/selector` |
| Required affinity mismatch | `N node(s) didn't match Pod's node affinity/selector` |
| Node cordoned | `N node(s) had untolerated taint {node.kubernetes.io/unschedulable:NoSchedule}` |
| Insufficient CPU | `N node(s) had Insufficient cpu` |
| Insufficient memory | `N node(s) had Insufficient memory` |

Note: nodeSelector and required affinity produce the same message text — to distinguish them, look at the pod spec.

---

## Scenario 1 — Taint without toleration

**How taints work:**

A taint has three parts: `key=value:effect`. The scheduler only places a pod on a tainted node if the pod has a toleration matching all three parts.

```yaml
# Toleration matching: dedicated=gpu:NoSchedule
tolerations:
- key: dedicated
  operator: Equal
  value: gpu
  effect: NoSchedule
```

**Taint effects:**

| Effect | What happens to scheduled pods |
|--------|-------------------------------|
| `NoSchedule` | New pods are not placed on the node. Existing pods are NOT evicted. |
| `PreferNoSchedule` | Scheduler tries to avoid the node but will use it if no alternative exists |
| `NoExecute` | New pods are not placed; existing pods WITHOUT a toleration are evicted |

**Why patch fails on pod tolerations:**

Pod specs are mostly immutable after creation. Fields like `tolerations`, `nodeSelector`, `affinity`, `containers`, and `volumes` cannot be changed via `kubectl patch` or `kubectl edit`. The only mutable pod fields are: `metadata.labels`, `metadata.annotations`, `spec.containers[*].image` (in some contexts via controllers), and `spec.initContainers[*].image`. To change scheduling constraints, you must delete and recreate the pod.

---

## Scenario 2 — Bad nodeSelector

**nodeSelector behavior:**

The scheduler evaluates nodeSelector as a hard requirement. Every key-value pair must match a node's labels exactly. If no node satisfies all conditions, the pod stays Pending indefinitely.

**Does adding a label to the node immediately schedule the Pending pod?**

Yes. The scheduler continuously re-evaluates Pending pods. When `kind-worker` gets the `disktype=nvme-ultra` label, the scheduler detects that the pod can now be placed there and schedules it immediately — no pod deletion needed.

**nodeSelector vs required affinity:**

```yaml
# nodeSelector — simpler syntax, exact match only
nodeSelector:
  disktype: ssd

# Node affinity — more expressive: In, NotIn, Exists, DoesNotExist, Gt, Lt operators
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: disktype
          operator: In
          values: [ssd, nvme]
```

Use nodeSelector for simple single-label matches. Use node affinity when you need multiple conditions, OR logic, or operators other than equality.

---

## Scenario 3 — Bad node affinity

**The required affinity rule:**

`requiredDuringSchedulingIgnoredDuringExecution` — the pod will only be placed on a node that matches the expression (required at scheduling time). If no node matches, the pod stays Pending.

`preferredDuringSchedulingIgnoredDuringExecution` — the scheduler tries to place the pod on a matching node but will fall back to any node if no match exists. Uses a weight (1–100) to rank preferences.

**"IgnoredDuringExecution":**

This means: once the pod is running, changes to the node's labels do NOT evict the pod. If `kind-worker` had label `kubernetes.io/hostname=kind-worker` and you removed that label, the pod would NOT be evicted — it would continue running. The affinity rule is only checked at scheduling time.

(Kubernetes 1.27+ added `requiredDuringSchedulingRequiredDuringExecution` as alpha — it would evict pods whose node no longer matches, but it's not stable yet.)

---

## Node conditions reference

| Condition | True means | Scheduling impact |
|-----------|-----------|-------------------|
| `Ready` | kubelet healthy, node accepting pods | `False` → controller-manager taints node with `NotReady:NoExecute` after 5 min |
| `MemoryPressure` | Available memory < threshold | Node gets `memory-pressure:NoSchedule` taint; BestEffort pods evicted |
| `DiskPressure` | Available disk < threshold | Node gets `disk-pressure:NoSchedule` taint; pods with large images evicted |
| `PIDPressure` | Process count near limit | Node gets `pid-pressure:NoSchedule` taint |

**Capacity vs Allocatable:**

```
Capacity = hardware total (e.g., 16 GB RAM, 8 CPUs)
Allocatable = Capacity minus:
  - kube-reserved: memory for kubelet, container runtime
  - system-reserved: memory for OS processes
  - eviction-threshold: memory kept free to avoid OOMKill
```

On a kind node, you typically see ~1–2 GB reserved for system processes. Pods can only use Allocatable, not Capacity.

---

## CKA scheduling troubleshooting checklist

When a pod is Pending:

```bash
# Step 1: where is it trying to go?
kubectl get pod <name> -n <ns> -o wide
# Should show <none> in NODE column if unscheduled

# Step 2: what is the scheduler saying?
kubectl describe pod <name> -n <ns> | grep -A 20 Events

# Step 3: check node state
kubectl get nodes                              # any NotReady or SchedulingDisabled?
kubectl describe node <node> | grep Taints    # any unexpected taints?
kubectl describe node <node> | grep -A 5 Allocatable  # enough capacity?

# Step 4: check pod spec
kubectl get pod <name> -n <ns> -o yaml | grep -A 20 nodeSelector
kubectl get pod <name> -n <ns> -o yaml | grep -A 20 affinity
kubectl get pod <name> -n <ns> -o yaml | grep -A 20 tolerations
```
