#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-11-resources and all resources within it..."
kubectl delete namespace lab-11-resources --ignore-not-found=true
echo "Done."
