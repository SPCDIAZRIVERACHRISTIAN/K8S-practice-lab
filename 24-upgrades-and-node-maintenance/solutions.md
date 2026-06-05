# Solutions — 24 Upgrades & Node Maintenance

---

## Cordon

`kubectl cordon <node>` adds the taint `node.kubernetes.io/unschedulable:NoSchedule` to the node. The node's status shows as `SchedulingDisabled`. The scheduler will not place any new pods on this node — but existing pods continue running unaffected.

**When to cordon without drain:**
- When you want to stop new pods from being placed on a node while you investigate an issue
- When you want to gradually migrate workloads (cordon, wait for pods to terminate naturally)
- As a preparatory step before a slow maintenance window where you want to empty the node over time

---

## Drain

`kubectl drain <node>` does two things:
1. **Cordons** the node (same as `kubectl cordon`)
2. **Evicts** all pods on the node (using the Eviction API, not `kubectl delete`)

The Eviction API respects PodDisruptionBudgets. If evicting a pod would violate a PDB, the eviction is denied and drain retries indefinitely.

**`--ignore-daemonsets`:**

DaemonSet pods cannot be moved — they are supposed to run on every node by definition. Without `--ignore-daemonsets`, drain fails immediately because it cannot evict DaemonSet pods. This flag tells drain to skip DaemonSet pods. They stay on the node and are recreated by the DaemonSet controller if the node is replaced.

**`--delete-emptydir-data`:**

emptyDir volumes store data in a directory on the node. When a pod is evicted, that directory is deleted and the data is gone. By default, drain refuses to evict pods with emptyDir to protect against accidental data loss. `--delete-emptydir-data` explicitly acknowledges that the data will be lost. Do not use this flag for pods with emptyDir that store important temporary data unless you are certain it is safe to lose.

**Why pods do not rebalance after uncordon:**

The Kubernetes scheduler only places pods when they are first created or rescheduled (e.g., after eviction). It does not spontaneously move running pods to rebalance the cluster. To rebalance:
- Delete pods manually (the ReplicaSet controller creates replacements, which are freshly scheduled)
- Scale down and up (forces rescheduling)
- Use the Descheduler project (a separate component that evicts pods for rebalancing)

---

## PodDisruptionBudget

A PDB limits how many pods of a given selector can be simultaneously unavailable during voluntary disruptions. "Voluntary" means: drain, rolling update, or any operation that uses the Eviction API. PDBs do NOT apply to involuntary disruptions (node failure, OOMKill, etc.).

### `minAvailable` vs `maxUnavailable`

```yaml
spec:
  minAvailable: 3    # at least 3 pods must always be available
  # OR
  maxUnavailable: 1  # at most 1 pod may be unavailable at any time
```

These are two ways to express the same constraint. Both accept integers or percentages (`"50%"`).

### ALLOWED DISRUPTIONS math

With a 4-replica deployment and `minAvailable: 3`:

```
Available pods = 4
Required minimum = 3
ALLOWED DISRUPTIONS = 4 - 3 = 1
```

You can evict 1 pod. If you try to evict a second pod while the first is still terminating (and hasn't been replaced yet), the eviction is denied.

**When drain blocks:**

When all 4 replicas are on two workers (roughly 2 per worker), draining `kind-worker2` requires evicting ~2 pods. After the first pod is evicted, available = 3. Evicting the second would bring available to 2, which is below `minAvailable: 3`. The drain prints:
```
error when evicting pods/"webapp-xxxx" -n "lab-24-maintenance" (will retry after 5s): 
Cannot evict pod as it would violate the pod's disruption budget.
```

The drain blocks and retries every 5 seconds. It does not fail immediately — it waits for the budget to allow eviction (which it never will unless you change the budget or scale up).

### Three ways to resolve PDB conflict

**Option A — Scale up first (recommended):**
Scale the Deployment to enough replicas that ALLOWED DISRUPTIONS > number of pods on the node being drained. This is the safest approach — you maintain availability throughout.

**Option B — Temporarily relax the PDB:**
Patch the PDB's `minAvailable` to a lower value during the maintenance window, drain, then restore the original PDB. This temporarily reduces protection but avoids scaling costs.

**Option C — Force drain (not recommended in production):**
```bash
kubectl drain <node> --force --disable-eviction --ignore-daemonsets --delete-emptydir-data
```
`--disable-eviction` bypasses the Eviction API entirely and deletes pods directly. PDBs are completely ignored. This can cause availability violations — use only in emergency situations (e.g., a node is failing and must be evacuated immediately regardless of impact).

---

## Node conditions

```
Conditions:
  Type               Status  Reason
  MemoryPressure     False   KubeletHasSufficientMemory
  DiskPressure       False   KubeletHasNoDiskPressure
  PIDPressure        False   KubeletHasSufficientPID
  Ready              True    KubeletReady
```

| Condition | `True` means |
|-----------|-------------|
| `Ready` | kubelet is healthy, node is accepting pods |
| `MemoryPressure` | Available memory is below a threshold; kubelet evicts BestEffort and Burstable pods |
| `DiskPressure` | Available disk is below a threshold; kubelet evicts pods using most disk |
| `PIDPressure` | Process IDs are exhausted; kubelet cannot start new processes |

**Capacity vs Allocatable:**

- `Capacity` — the node's total hardware resources (CPU cores, memory bytes)
- `Allocatable` — what Kubernetes can actually schedule to pods (total minus what kubelet, system processes, and the OS reserve)

A node with 4 CPU might show Allocatable as 3800m because the kubelet reserves 200m for itself.

---

## kubeadm worker node upgrade — step-by-step

```
1. Upgrade kubeadm binary on the worker node
2. kubeadm upgrade node          → downloads config from API server, upgrades CNI and kubelet config
3. kubectl drain <node>           → evict pods, put node in maintenance mode
4. Upgrade kubelet and kubectl binaries
5. systemctl daemon-reload && systemctl restart kubelet
6. kubectl uncordon <node>        → return node to service
7. Verify: kubectl get nodes      → version should show updated
```

**Why drain before upgrading kubelet:**

The kubelet restart (step 5) takes the node briefly out of service. During the restart, running pods are unaffected (containerd manages them independently of kubelet). But if kubelet is restarted while serving pods, there is a window where the API server cannot get health information from the node. Draining first ensures no workloads depend on this node during the upgrade window.

**`apt-mark hold`:**

`apt-mark hold <package>` prevents `apt-get upgrade` or `apt-get dist-upgrade` from upgrading the package without explicit intent. Without this, a routine `apt upgrade` on the node would update Kubernetes binaries to the latest available version, potentially skipping minor version constraints and breaking the cluster. kubelet, kubeadm, and kubectl should only be upgraded deliberately as part of a planned cluster upgrade.

---

## CKA drain command — memorize this

```bash
kubectl drain <node-name> \
  --ignore-daemonsets \
  --delete-emptydir-data
```

This is the version you use 99% of the time. Add `--grace-period=0` only when you need immediate eviction (skips the pod's `terminationGracePeriodSeconds`).

**Check before draining:**
```bash
kubectl get pdb --all-namespaces
kubectl describe pdb <name> -n <ns>  # check ALLOWED DISRUPTIONS
```

If ALLOWED DISRUPTIONS is 0, the drain will block. Scale up or adjust the PDB first.
