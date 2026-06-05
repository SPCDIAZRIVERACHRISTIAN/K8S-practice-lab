#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-03-rollouts and all resources within it..."
kubectl delete namespace lab-03-rollouts --ignore-not-found=true
echo "Done."
