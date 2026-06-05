# Commands — 23 etcd Backup & Restore Concept Lab

---

## 1. Create the test objects

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/test-configmap.yaml
kubectl apply -f manifests/test-secret.yaml
```

```bash
kubectl get all,cm,secret -n lab-23-etcd
```

> These objects are now stored in etcd. Taking a snapshot after this step will include them.

---

## 2. Find the etcd pod and inspect it

```bash
kubectl get pods -n kube-system -l component=etcd
```

> What is the full pod name? Note it — you'll use it in the etcdctl commands.

```bash
kubectl describe pod etcd-kind-control-plane -n kube-system | grep -E "Command|--listen|--cert|--key|--ca"
```

> Find the three cert-related flags etcd uses. Write them down — you need these for every etcdctl command:
> - `--trusted-ca-file` → used as `--cacert` in etcdctl
> - `--cert-file` → used as `--cert` in etcdctl
> - `--key-file` → used as `--key` in etcdctl

---

## 3. Set the etcdctl API version

The kind etcd image ships with etcdctl v3. Always set the API version explicitly:

```bash
kubectl exec -it etcd-kind-control-plane -n kube-system -- \
  sh -c "ETCDCTL_API=3 etcdctl version"
```

> What version of etcdctl is installed? What does `ETCDCTL_API=3` do?

---

## 4. Check etcd member list

```bash
kubectl exec -it etcd-kind-control-plane -n kube-system -- \
  etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

> How many members are in the etcd cluster? In kind there is one — this is not HA.
> In production, a highly available etcd cluster has how many members?

---

## 5. Check etcd endpoint health

```bash
kubectl exec -it etcd-kind-control-plane -n kube-system -- \
  etcdctl endpoint health \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

> What does "healthy" mean here? What would "unhealthy" look like?

---

## 6. Check etcd endpoint status

```bash
kubectl exec -it etcd-kind-control-plane -n kube-system -- \
  etcdctl endpoint status \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --write-out=table
```

> Find the `Revision` field. What does the revision number represent?
> Find the `DB SIZE` field. This is how much data etcd is storing.

---

## 7. Take a snapshot — manual approach

```bash
kubectl exec -it etcd-kind-control-plane -n kube-system -- \
  etcdctl snapshot save /tmp/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

> What does "Snapshot saved at /tmp/etcd-snapshot.db" confirm?

---

## 8. Verify the snapshot

```bash
kubectl exec -it etcd-kind-control-plane -n kube-system -- \
  etcdctl snapshot status /tmp/etcd-snapshot.db \
  --write-out=table
```

> The table shows: Hash, Revision, Total Keys, Total Size.
> - What is the revision number? Is it higher than when you checked endpoint status?
> - Roughly how many keys does etcd hold for a fresh kind cluster?

---

## 9. Copy the snapshot out of the container

```bash
ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd \
  -o jsonpath='{.items[0].metadata.name}')

kubectl cp kube-system/${ETCD_POD}:/tmp/etcd-snapshot.db ./etcd-snapshot.db
```

```bash
ls -lh etcd-snapshot.db
```

> Why must you copy the snapshot out of the container? What happens to files in the container if the pod restarts?

> In production, where should etcd snapshots be stored?

---

## 10. Automated approach

```bash
./scripts/backup-etcd.sh
```

> The script does everything from steps 7–9 in one command. Review its contents and identify each step.

---

## 11. Inspect etcd key-value data (read-only)

See the raw key count for a namespace:

```bash
kubectl exec -it etcd-kind-control-plane -n kube-system -- \
  etcdctl get /registry/namespaces/lab-23-etcd \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

> The output is binary/protobuf-encoded. But you can see the namespace name in the data.

```bash
kubectl exec -it etcd-kind-control-plane -n kube-system -- \
  etcdctl get /registry/ \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --prefix --keys-only | head -30
```

> What key prefixes do you see? How does etcd organize Kubernetes resources?

---

## 12. The restore procedure — read-only study

**Do not run these commands in your kind cluster.** Study them and understand each step.

On a production kubeadm node, the restore procedure is:

```bash
# Step 1: Take the backup (already done)
# (etcdctl snapshot save ...)

# Step 2: Stop the API server by moving its static pod manifest out of the watched directory
# This prevents the API server from writing to etcd during the restore
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/kube-apiserver.yaml.bak

# Step 3: Stop the controller manager and scheduler too
sudo mv /etc/kubernetes/manifests/kube-controller-manager.yaml /tmp/
sudo mv /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/

# Step 4: Restore the snapshot to a new data directory
ETCDCTL_API=3 etcdctl snapshot restore /path/to/etcd-snapshot.db \
  --data-dir=/var/lib/etcd-restored \
  --name=kind-control-plane \
  --initial-cluster=kind-control-plane=https://127.0.0.1:2380 \
  --initial-cluster-token=etcd-cluster-1 \
  --initial-advertise-peer-urls=https://127.0.0.1:2380

# Step 5: Update the etcd static pod manifest to use the new data directory
# Edit /etc/kubernetes/manifests/etcd.yaml:
#   change --data-dir from /var/lib/etcd to /var/lib/etcd-restored
#   change hostPath for the data volume accordingly

# Step 6: Move the static pod manifests back to restart all components
sudo mv /tmp/kube-apiserver.yaml.bak /etc/kubernetes/manifests/kube-apiserver.yaml
sudo mv /tmp/kube-controller-manager.yaml /etc/kubernetes/manifests/
sudo mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests/

# Step 7: Wait for the API server to come back up
kubectl get nodes
```

> Answer these questions:
> - Why must the API server be stopped before restoring etcd?
> - What does `--data-dir` specify in the restore command?
> - After restore, the cluster state returns to the snapshot point. What objects are lost?
> - What is `--initial-cluster-token` for?

---

## 13. What the CKA exam asks

On the CKA, the backup/restore question typically asks you to:
1. Save an etcd snapshot to a specific path (e.g., `/opt/etcd-backup.db`)
2. Restore a provided snapshot
3. Verify the cluster is functional after restore

Practice writing the `etcdctl snapshot save` command without looking at notes:

```bash
ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=__FILL_IN__ \
  --cert=__FILL_IN__ \
  --key=__FILL_IN__
```

> Fill in the three cert paths from memory. Where do you find them if you forget?
> Hint: `kubectl describe pod etcd-... -n kube-system` shows the exact paths.
