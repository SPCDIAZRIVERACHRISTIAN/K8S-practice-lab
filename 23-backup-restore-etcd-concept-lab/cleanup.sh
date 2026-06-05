#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-23-etcd..."
kubectl delete namespace lab-23-etcd --ignore-not-found=true

echo "Removing snapshot file if present..."
rm -f ./etcd-snapshot.db
rm -f /tmp/etcd-backup.db

echo "Done."
