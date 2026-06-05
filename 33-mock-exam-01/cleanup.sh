#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning up Mock Exam 01..."

# Delete namespaces
kubectl delete namespace exam-01 --ignore-not-found=true
kubectl delete namespace exam-01-broken --ignore-not-found=true

# Remove taint from kind-worker if still present
kubectl taint node kind-worker env=test:NoSchedule- 2>/dev/null || true

# Uncordon kind-worker2 if still cordoned
kubectl uncordon kind-worker2 2>/dev/null || true

# Remove etcd snapshot
rm -f /tmp/etcd-exam-backup.db

# Remove temp files
rm -f /tmp/web-deploy.yaml

echo "Cleanup complete."
