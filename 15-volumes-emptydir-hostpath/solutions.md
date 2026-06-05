# Solutions — 15 Volumes: emptyDir and hostPath

---

## Volume lifecycle vs container lifecycle

A container's writable layer is wiped every time the container restarts. A volume is mounted into the container and can outlive an individual container restart — but its own lifetime depends on the volume type.

| Volume type | Lifetime | Backed by |
|-------------|---------|-----------|
| Container writable layer | Container lifetime | Container overlay filesystem |
| emptyDir | Pod lifetime | Node RAM or local disk |
| hostPath | Node lifetime (not pod) | Node filesystem directory |
| PersistentVolume | Independent of pod | Network storage, cloud disk, etc. |

---

## emptyDir

An emptyDir volume is created when the pod is scheduled to a node and destroyed when the pod is removed from that node (for any reason: deletion, eviction, node reboot).

**It survives container restarts within the same pod.** If a container crashes and kubelet restarts it, the emptyDir data is still there. But if the pod itself is deleted and recreated, the new pod gets a fresh empty directory.

**Where it lives:** The emptyDir is created in a temporary directory on the node's local filesystem (under `/var/lib/kubelet/pods/<pod-uid>/volumes/`). You cannot see this path from inside the pod — you just see your `mountPath`.

**emptyDir primary use case:** Sharing scratch data between two containers in the same pod. For example: a sidecar that processes files written by the main container; a git-sync container that clones a repo into an emptyDir that a web server container reads.

---

## hostPath

A hostPath volume mounts a directory from the node's filesystem into the pod. The data lives on the node, not in the pod. When the pod is deleted, the directory and its files remain on the node.

**The node-pinning problem:**
If the pod is rescheduled to a different node (due to node failure, drain, or scaling), the new pod on the new node will mount a new (empty or nonexistent) directory. The old data is stranded on the original node.

To work around this, you would need:
- A `nodeSelector` or node affinity to force the pod back to the same node — but this breaks HA
- Or a real network-backed PersistentVolume, which moves with the pod claim

**Security risk:** A container with a hostPath volume that mounts `/etc` or `/var/run/docker.sock` from the node can read and modify the host. hostPath volumes give pods direct access to node filesystem paths, making them a container escape vector if misused.

---

## What you need for durable storage

Neither emptyDir nor hostPath is appropriate for a database. You need:

1. **PersistentVolume (PV)** — a cluster-scoped storage resource
2. **PersistentVolumeClaim (PVC)** — a namespaced request for storage
3. **StorageClass** — defines the provisioner that creates PVs dynamically

With a PVC, the storage is independent of the pod. If the pod is deleted and recreated (even on a different node), the claim re-attaches to the same PV and the data is intact. This is covered in lab 16.

---

## Common mistakes

**Using emptyDir for data you need to survive pod restarts**
emptyDir data survives container restarts (within the same pod) but NOT pod deletion. If your Deployment rolls out a new pod, it is a different pod — the old emptyDir is gone.

**Using hostPath in a multi-node cluster**
Works fine in single-node kind for demos. In production multi-node clusters, hostPath is almost always the wrong choice. Use PVCs with a network storage backend.

**Confusing volume mounts with container filesystem writes**
If you write to a path that is NOT a volume mount, you are writing to the container's overlay filesystem. That data is lost when the container restarts. You must explicitly mount a volume at the path you want to persist.
