#!/usr/bin/env bash
set -euo pipefail

echo "Removing Kustomize deployments..."
kubectl delete namespace lab-20-dev --ignore-not-found=true
kubectl delete namespace lab-20-prod --ignore-not-found=true

echo "Uninstalling Helm release if present..."
if helm list -n lab-20-helm 2>/dev/null | grep -q my-nginx; then
  helm uninstall my-nginx -n lab-20-helm
else
  echo "  Helm release my-nginx not found, skipping."
fi

echo "Deleting Helm namespace..."
kubectl delete namespace lab-20-helm --ignore-not-found=true

echo "Done."
