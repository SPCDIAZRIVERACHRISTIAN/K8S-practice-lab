#!/usr/bin/env bash
set -euo pipefail

echo "Removing custom taints from nodes if present..."
kubectl taint node kind-worker dedicated=gpu:NoSchedule- 2>/dev/null || true
kubectl taint node kind-worker2 dedicated=gpu:NoSchedule- 2>/dev/null || true

echo "Removing custom labels from nodes if present..."
kubectl label node kind-worker disktype- 2>/dev/null || true
kubectl label node kind-worker2 disktype- 2>/dev/null || true

echo "Uncordoning nodes if cordoned..."
kubectl uncordon kind-worker 2>/dev/null || true
kubectl uncordon kind-worker2 2>/dev/null || true

echo "Deleting namespace lab-29-nodes..."
kubectl delete namespace lab-29-nodes --ignore-not-found=true

echo "Done."
