#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-02-deployments and all resources within it..."
kubectl delete namespace lab-02-deployments --ignore-not-found=true
echo "Done."
