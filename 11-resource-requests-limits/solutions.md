# Solutions — 11 Resource Requests and Limits

---

## Requests vs limits

| | Request | Limit |
|--|---------|-------|
| Purpose | Scheduling hint — "I need at least this much" | Runtime cap — "You cannot use more than this" |
| Used by | Scheduler (to find a node with enough room) | kubelet (to enforce via cgroups) |
| CPU behavior | Soft reservation | Throttled — process slows down but is not killed |
| Memory behavior | Soft reservation | Hard cap — process is killed (OOMKilled) if exceeded |

CPU over-limit → throttled. Memory over-limit → killed. This asymmetry matters.

---

## QoS classes

Kubernetes assigns a QoS class automatically based on requests and limits:

| Class | Rule | Priority when node is under pressure |
|-------|------|--------------------------------------|
| Guaranteed | requests == limits for every container, both CPU and memory | Last to be evicted |
| Burstable | At least one container has requests, but requests != limits | Evicted second |
| BestEffort | No requests and no limits on any container | First to be evicted |

The QoS class is shown in `kubectl describe pod` under `QoS Class`.

---

## Why the unschedulable pod stays Pending

The scheduler looks for a node where `Allocatable memory >= pod's memory request`. Kind worker nodes in a default setup typically have 2–8Gi of allocatable memory. A request of 100Gi cannot be satisfied, so the pod stays Pending forever.

Expected event:
```
0/3 nodes are available: 1 node(s) had untolerated taint, 2 Insufficient memory.
```

To fix: lower the memory request to something the cluster can actually provide.

---

## What OOMKilled means

When a container's memory usage hits its limit, the Linux kernel OOM (Out-Of-Memory) killer sends SIGKILL to the container process. The container exits with a non-zero code.

kubelet sees the container exit and marks it with reason `OOMKilled`. The pod enters CrashLoopBackOff if it keeps restarting.

Expected `kubectl describe pod pod-oom` output under `Last State`:
```
Last State: Terminated
  Reason:   OOMKilled
  Exit Code: 137
```

Exit code 137 = 128 + 9 (SIGKILL).

---

## CPU throttling vs memory killing

This is a critical distinction for the CKA:

- **CPU limit exceeded** → the container is throttled. It runs slower. It is NOT killed. It stays running.
- **Memory limit exceeded** → the container is killed. OOMKilled. The pod restarts.

Setting a memory limit that is too low is a silent production killer: your app appears to be running but is actually being OOMKilled repeatedly, causing CrashLoopBackOff and downtime.

---

## Common mistakes

**Setting limits without requests**
If you only set `limits` and no `requests`, Kubernetes sets requests equal to limits. The QoS class will be Guaranteed. This may cause scheduling failures if the node cannot fit the resource reservation.

**Setting limits too low in production**
Limits that are too tight cause OOMKilled in production. Always measure actual memory usage before setting limits.

**Forgetting that CPU is measured in millicores**
`cpu: "1"` = 1 full CPU core. `cpu: "100m"` = 0.1 CPU core (100 millicores). A pod with `cpu: "0.5"` and `cpu: "500m"` are identical.

**Assuming BestEffort pods are fine for important workloads**
BestEffort pods are the first to be evicted under node memory pressure. Use Guaranteed or Burstable QoS for any workload that matters.
