# Solutions — 23 etcd Backup & Restore Concept Lab

---

## What etcd stores

etcd is a distributed key-value store that holds the entire Kubernetes cluster state. Every object you create with `kubectl apply` is serialized (via protobuf) and stored in etcd. This includes:

- Pods, Deployments, ReplicaSets, StatefulSets, DaemonSets, Jobs, CronJobs
- Services, Endpoints, EndpointSlices, Ingresses, NetworkPolicies
- ConfigMaps, Secrets
- Nodes (registration data), PersistentVolumes, PersistentVolumeClaims, StorageClasses
- Namespaces, ServiceAccounts, Roles, RoleBindings, ClusterRoles, ClusterRoleBindings
- CustomResourceDefinitions and all custom resources
- kubeadm configuration (as ConfigMaps in kube-system)

The key structure is `/registry/<resource-type>/<namespace>/<name>`. For example:
```
/registry/pods/default/nginx-abc123
/registry/deployments/production/webapp
/registry/secrets/kube-system/bootstrap-token-abcdef
```

**If etcd data is permanently lost with no backup:**

The API server has no state to serve. Every object, every workload, every configuration is gone. The cluster is unrecoverable except by rebuilding from scratch and reapplying all manifests. This is why etcd backup is the most critical operational procedure for a Kubernetes cluster.

---

## etcdctl authentication

Every `etcdctl` command in a TLS-secured etcd cluster requires three cert flags:

```bash
--endpoints=https://127.0.0.1:2379        # where etcd listens
--cacert=/etc/kubernetes/pki/etcd/ca.crt  # etcd's CA — verify the server
--cert=/etc/kubernetes/pki/etcd/server.crt # client cert — prove your identity
--key=/etc/kubernetes/pki/etcd/server.key  # client key — sign your requests
```

**Where to find these paths if you forget them:**

```bash
kubectl describe pod etcd-<node-name> -n kube-system | grep -E "cacert|cert-file|key-file|endpoints"
```

The flags in the etcd pod command map directly:
- `--trusted-ca-file` → `--cacert`
- `--cert-file` → `--cert`
- `--key-file` → `--key`
- `--listen-client-urls` → `--endpoints`

**`ETCDCTL_API=3`:**

etcdctl supports two protocol versions: v2 (deprecated) and v3 (current). Kubernetes uses etcd v3. Without setting `ETCDCTL_API=3`, some commands default to v2 and fail or return empty results. Always set this environment variable:

```bash
export ETCDCTL_API=3
```

or prefix it on each command:
```bash
ETCDCTL_API=3 etcdctl snapshot save ...
```

**`etcdctl endpoint status` fields:**

| Field | Meaning |
|-------|---------|
| Endpoint | The etcd client endpoint URL |
| ID | The unique member ID in the etcd cluster |
| Version | etcd server version |
| DB SIZE | Total size of the etcd database on disk |
| IS LEADER | Whether this member is the current Raft leader |
| IS LEARNER | Whether this is a non-voting learner node |
| Raft Term | The current Raft election term |
| Raft Index | The current log index |
| **Revision** | The number of writes ever made to etcd. Monotonically increasing. Each kubectl create/update/delete increments this. |

---

## Backup procedure

```bash
ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

**Verifying the snapshot:**

```bash
ETCDCTL_API=3 etcdctl snapshot status /opt/etcd-backup.db --write-out=table
```

This shows: hash, revision, total key count, and file size. If any of these are 0 or the command fails, the snapshot is corrupt.

**Why copy the snapshot out of the container:**

Files inside a container's filesystem are ephemeral. If the etcd pod restarts, the files in `/tmp/` are gone. Additionally, if etcd itself is the problem (data corruption, disk failure), you cannot access a snapshot stored inside the container. The snapshot must be stored:

- On a different host (not the same node as etcd)
- In object storage (S3, GCS, Azure Blob)
- On a volume that is not the etcd data volume

In production, use a CronJob or a dedicated backup operator to take snapshots on a schedule and upload them off-cluster.

---

## Restore procedure — full reference

**This procedure replaces all cluster state with the snapshot's state. Run only in a controlled environment.**

```bash
# Step 1: Stop the API server (prevents writes to etcd during restore)
# Move its static pod manifest out of the watched directory
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/kube-apiserver.yaml.bak

# Also stop the controller-manager and scheduler
sudo mv /etc/kubernetes/manifests/kube-controller-manager.yaml /tmp/
sudo mv /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/

# Wait for the API server pod to disappear (kubelet stops it within ~30 seconds)

# Step 2: Restore the snapshot to a new data directory
ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup.db \
  --data-dir=/var/lib/etcd-restored \
  --name=kind-control-plane \
  --initial-cluster=kind-control-plane=https://127.0.0.1:2380 \
  --initial-cluster-token=etcd-cluster-restored \
  --initial-advertise-peer-urls=https://127.0.0.1:2380

# Step 3: Update the etcd static pod manifest to point to the new data directory
# Find and replace the data-dir value:
sudo sed -i 's|/var/lib/etcd|/var/lib/etcd-restored|g' \
  /etc/kubernetes/manifests/etcd.yaml
# Also update the hostPath volume to match

# Step 4: Move control plane manifests back — kubelet restarts all components
sudo mv /tmp/kube-apiserver.yaml.bak /etc/kubernetes/manifests/kube-apiserver.yaml
sudo mv /tmp/kube-controller-manager.yaml /etc/kubernetes/manifests/
sudo mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests/

# Step 5: Verify the cluster is back
kubectl get nodes
kubectl get pods -A
```

**Why the API server must be stopped first:**

If the API server is running while etcd is being restored, it can write new state to etcd. When the restore completes, those writes would be wiped (they were not in the snapshot). Worse, etcd's Raft log would be inconsistent, potentially corrupting the restored data. Stopping the API server ensures no writes happen during the restore window.

**What `--data-dir` does:**

The restore command does not write into the existing etcd data directory. It creates a fresh data directory from the snapshot at the path you specify. This is safe — the original data directory is untouched until you update the static pod manifest to point to the new directory.

**What `--initial-cluster-token` does:**

This sets the cluster token for the new etcd instance started from the restore. It must be different from the original token to prevent the restored instance from accidentally joining the original cluster if both are running simultaneously. Use any value.

**After restore — what state is recovered, what is lost:**

| Recovered | Lost |
|-----------|------|
| All objects that existed at snapshot time | Any objects created AFTER the snapshot |
| All cluster configuration | Any writes made after the snapshot was taken |
| All secrets and configmaps as of snapshot | New deployments, service account tokens rotated after snapshot |

This is why in production, etcd snapshots are taken frequently (every 15–30 minutes) and point-in-time recovery is designed around acceptable data loss windows (RPO).

---

## CKA exam reference — the complete backup command

Memorize this. The exam provides the endpoint and cert paths in the question, but knowing where to look helps:

```bash
ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

If the exam question gives different cert paths, use those. The command structure is always the same. The `--write-out=table` flag is optional but shows the snapshot details after save.

**Fastest way to find cert paths on exam:**
```bash
grep -A 1 "\-\-cert\|\-\-key\|\-\-ca" /etc/kubernetes/manifests/etcd.yaml
```
