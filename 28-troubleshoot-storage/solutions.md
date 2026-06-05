# Solutions — 28 Troubleshoot Storage

---

## PVC status meanings

| Status | Meaning |
|--------|---------|
| `Pending` | No PV available or no provisioner can fulfill the request |
| `Bound` | A PV has been assigned and the PVC is ready to use |
| `Lost` | The bound PV no longer exists (data likely gone) |
| `Terminating` | PVC is being deleted but a pod still holds a reference to it |

---

## Scenario 1 — Wrong StorageClass

**Events output from `kubectl describe pvc pvc-wrong-sc`:**
```
Events:
  Type     Reason                Age   From                         Message
  ----     ------                ----  ----                         -------
  Warning  ProvisioningFailed    5s    persistentvolume-controller  storageclass.storage.k8s.io "fast-nvme-does-not-exist" not found
```

The PVC controller looks for a StorageClass with that name. If none exists, no provisioner is invoked and the PVC stays Pending indefinitely.

**Why you cannot patch `storageClassName`:**

The `storageClassName` field in a PVC spec is immutable after creation. The Kubernetes API server rejects the patch with `Forbidden: spec.storageClassName is immutable after creation`. The fix is to delete the PVC and create a new one with the correct class.

**Available StorageClasses in kind:**
```
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWEDTOPOLOGIES
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   <none>
```

`standard` is the only StorageClass in a default kind cluster. `WaitForFirstConsumer` means the PV is not actually provisioned until a pod references the PVC.

---

## Scenario 2 — Wrong Access Mode

**Access modes:**

| Mode | Abbreviation | Meaning |
|------|-------------|---------|
| ReadWriteOnce | RWO | Mounted read-write by ONE node at a time |
| ReadOnlyMany | ROX | Mounted read-only by MANY nodes simultaneously |
| ReadWriteMany | RWX | Mounted read-write by MANY nodes simultaneously |
| ReadWriteOncePod | RWOP | Mounted read-write by ONE pod (Kubernetes 1.22+) |

**Why local-path only supports RWO:**

kind's `local-path` provisioner creates volumes on the node's local filesystem (under `/var/local-path-provisioner/`). A local directory can only be bind-mounted on one node — you cannot share it across nodes. RWX requires a shared network filesystem (NFS, GlusterFS, CephFS, Amazon EFS, etc.) that multiple nodes can mount simultaneously.

**The describe Events output:**
```
Events:
  Warning  ProvisioningFailed  no persistent volumes available for this claim and no storage class is set
```

Or depending on the provisioner version:
```
Warning  ProvisioningFailed  storageclass does not support ReadWriteMany
```

---

## Scenario 3 — Pod with Missing PVC

**ContainerCreating with missing PVC — Events:**
```
Events:
  Warning  FailedMount  Unable to attach or mount volumes: unmounted volumes=[data], ...
  Warning  FailedMount  MountVolume.SetUp failed ... persistentvolumeclaim "does-not-exist-pvc" not found
```

**Does the pod recover automatically?**

Yes. kubelet continuously retries mounting volumes. Once the PVC exists AND is Bound, kubelet picks it up on the next retry (within a few seconds to a minute). You do not need to delete and recreate the pod.

**What this means:**

In a deployment pipeline, you can create PVCs before the pods that use them — the pods will start as soon as the PVCs are ready. This is the correct pattern: infrastructure (PVCs) before workloads (pods).

---

## Scenario 4 — StatefulSet volumeClaimTemplates immutability

**Patch error:**
```
The StatefulSet "broken-db" is invalid: spec.volumeClaimTemplates: Forbidden: updates to statefulset spec for fields other than 'replicas', 'ordinals', 'template', 'updateStrategy', 'persistentVolumeClaimRetentionPolicy' and 'minReadySeconds' are forbidden.
```

**Why immutable:**

A StatefulSet's `volumeClaimTemplates` defines the PVC template used when the StatefulSet first creates each pod's PVC. Once those PVCs exist, changing the template would not affect the existing PVCs (they were already created). Kubernetes makes it immutable to prevent confusion: you cannot update the template and expect existing PVCs to change. The template only applies to new PVCs.

**Correct fix procedure:**

1. Scale down to 0 (releases the PV mounts from pods)
2. Delete the StatefulSet (does NOT delete PVCs automatically)
3. Delete the PVCs manually (because they are bound to wrong-class PVs, or are still Pending)
4. Recreate the StatefulSet with the correct `storageClassName`

**What happens if you delete the StatefulSet without deleting PVCs:**

The PVCs are orphaned — they persist in the namespace and consume storage. When you recreate the StatefulSet, it will try to create new PVCs with the same names (`storage-broken-db-0`, `storage-broken-db-1`). If the old PVCs still exist, the StatefulSet will attempt to use them — which may be the wrong StorageClass or in a broken state. Always delete orphaned PVCs before recreating a StatefulSet with changed volumeClaimTemplates.

---

## Common CKA storage triage flow

```
kubectl get pvc -n <ns>         # find Pending PVCs
kubectl describe pvc <name>     # read Events for root cause
kubectl get storageclass        # check available classes
kubectl get pv                  # check available PVs (if static provisioning)
kubectl describe pod <name>     # find volume mount failures (ContainerCreating)
```
