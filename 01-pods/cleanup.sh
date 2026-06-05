#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-01-pods and all resources within it..."
kubectl delete namespace lab-01-pods --ignore-not-found=true
echo "Done."
