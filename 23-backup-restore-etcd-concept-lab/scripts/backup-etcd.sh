#!/usr/bin/env bash
# Takes an etcd snapshot from inside the etcd pod in the kind cluster.
# The snapshot file lands inside the etcd container at /tmp/etcd-snapshot.db,
# then gets copied to ./etcd-snapshot.db in the current directory.
set -euo pipefail

SNAPSHOT_PATH="/tmp/etcd-snapshot.db"
ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}')

echo "Found etcd pod: ${ETCD_POD}"
echo "Taking snapshot inside etcd container..."

kubectl exec -n kube-system "${ETCD_POD}" -- \
  etcdctl snapshot save "${SNAPSHOT_PATH}" \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

echo "Verifying snapshot inside container..."
kubectl exec -n kube-system "${ETCD_POD}" -- \
  etcdctl snapshot status "${SNAPSHOT_PATH}" \
  --write-out=table

echo "Copying snapshot out of container..."
kubectl cp "kube-system/${ETCD_POD}:${SNAPSHOT_PATH}" ./etcd-snapshot.db

echo ""
echo "Snapshot saved to: $(pwd)/etcd-snapshot.db"
echo "Size: $(du -sh ./etcd-snapshot.db | cut -f1)"
