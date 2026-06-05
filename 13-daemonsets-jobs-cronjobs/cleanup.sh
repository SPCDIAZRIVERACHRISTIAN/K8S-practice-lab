#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-13-workloads and all resources within it..."
kubectl delete namespace lab-13-workloads --ignore-not-found=true
echo "Done."
