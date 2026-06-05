#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-18-rbac (removes all namespaced resources)..."
kubectl delete namespace lab-18-rbac --ignore-not-found=true

echo "Removing any cluster-scoped test resources..."
kubectl delete rolebinding view-in-ns -n lab-18-rbac --ignore-not-found=true 2>/dev/null || true

echo "Done."
