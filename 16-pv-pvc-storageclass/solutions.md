# Solutions — 16 PersistentVolumes, PersistentVolumeClaims, and StorageClass

---

## The three-layer storage model

```
StorageClass
  └── defines: provisioner, parameters, reclaim policy, binding mode
        ↓ (when a PVC references this StorageClass)
PersistentVolume
  └── cluster-scoped resource representing actual storage
        ↓ (when a PVC binds to a PV)
PersistentVolumeClaim
  └── namespaced request for storage — what pods reference
        ↓ (pod mounts the claim)
Pod
  └── sees /data as a filesystem directory
```

Pods never reference PVs directly. They reference PVCs. The PVC/PV binding is the layer of indirection that makes storage portable across pod recreations and rescheduling.

---

## Dynamic provisioning

With dynamic provisioning, you do not pre-create PVs. The StorageClass provisioner creates a PV automatically when a PVC is submitted.

Workflow:
1. You create a PVC specifying `storageClassName: standard` and `storage: 100Mi`
2. The PVC controller asks the `rancher.io/local-path` provisioner to create a PV
3. kind's local-path provisioner creates a directory on a node and registers a PV object
4. The PV is bound to the PVC
5. The pod mounts the PVC and sees the directory

---

## Why the PVC was Pending before the pod was created

kind uses the `local-path` provisioner with `VolumeBindingMode: WaitForFirstConsumer`. This means the provisioner does not create the PV until a pod actually tries to use the claim. This is intentional — it lets the provisioner pick the correct node (the one where the pod is scheduled) rather than creating storage on a random node.

Once you applied the pod, the scheduler assigned a node, and the provisioner created the PV on that node.

---

## Access modes

| Mode | Abbreviation | Meaning |
|------|-------------|---------|
| ReadWriteOnce | RWO | One node can mount read-write |
| ReadOnlyMany | ROX | Many nodes can mount read-only |
| ReadWriteMany | RWX | Many nodes can mount read-write |
| ReadWriteOncePod | RWOP | One pod can mount read-write (k8s 1.22+) |

kind's local-path provisioner only supports `ReadWriteOnce`. Network storage backends (NFS, Ceph, cloud block storage) support additional modes.

---

## Reclaim policies

| Policy | What happens when PVC is deleted |
|--------|----------------------------------|
| `Delete` | PV and underlying storage are deleted automatically |
| `Retain` | PV remains, status changes to `Released`. Data is preserved but the PV cannot be rebound automatically until manually reclaimed. |
| `Recycle` | Deprecated — scrubs the volume and makes it Available again |

kind's local-path provisioner uses `Delete` by default. After you delete the PVC, the PV and its backing directory are deleted.

---

## What happens to a pod referencing a Pending PVC

A pod that references a PVC that is in `Pending` or does not exist will itself stay `Pending`. It cannot be scheduled because the volume it needs is not available.

Event in pod describe:
```
Warning  FailedMount  ...  Unable to attach or mount volumes: ... persistentvolumeclaim "broken-pvc" not found
```

The pod is waiting for the storage, not for a node. This is a common source of "my pods are stuck in Pending" in production.

---

## Data persistence vs emptyDir/hostPath

| Volume | Survives container restart | Survives pod deletion | Survives rescheduling to new node |
|--------|--------------------------|----------------------|----------------------------------|
| emptyDir | ✅ | ❌ | ❌ |
| hostPath | ✅ | ✅ (same node) | ❌ |
| PVC (network storage) | ✅ | ✅ | ✅ |
| PVC (local-path) | ✅ | ✅ | ❌ (node-local) |

Even kind's local-path PVCs are node-local under the hood. For truly portable PVCs, you need a network-backed StorageClass (cloud provider block storage, Ceph, NFS, etc.).

---

## Common mistakes

**Using the wrong StorageClass name**
`does-not-exist` as a storageClassName creates a PVC that waits forever. Always run `kubectl get storageclass` first to see what is available.

**Forgetting that PVCs are namespaced but PVs are cluster-scoped**
A PVC in `namespace-a` cannot bind to a PV claimed by a PVC in `namespace-b`. Each namespace gets its own PVC → PV binding.

**Deleting a PVC while a pod is using it**
Kubernetes will not delete the PVC immediately. It will set the PVC status to `Terminating` but keep it alive until the pod is deleted. The PVC is stuck until no pod references it.
