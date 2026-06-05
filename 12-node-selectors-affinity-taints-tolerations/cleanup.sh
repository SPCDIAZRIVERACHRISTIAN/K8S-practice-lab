#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-12-scheduling..."
kubectl delete namespace lab-12-scheduling --ignore-not-found=true

echo "Removing disktype label from all nodes (if present)..."
kubectl label nodes --all disktype- 2>/dev/null || true

echo "Removing dedicated=special:NoSchedule taint from all nodes (if present)..."
kubectl taint nodes --all dedicated=special:NoSchedule- 2>/dev/null || true

echo "Done."
echo "Note: verify taints are cleared with: kubectl describe nodes | grep Taints"
