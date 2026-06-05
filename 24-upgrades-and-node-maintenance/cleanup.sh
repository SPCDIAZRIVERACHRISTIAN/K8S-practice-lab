#!/usr/bin/env bash
set -euo pipefail

echo "Uncordoning any cordoned nodes..."
kubectl uncordon kind-worker 2>/dev/null || true
kubectl uncordon kind-worker2 2>/dev/null || true

echo "Deleting namespace lab-24-maintenance..."
kubectl delete namespace lab-24-maintenance --ignore-not-found=true

echo "Verifying nodes are schedulable..."
kubectl get nodes

echo "Done."
