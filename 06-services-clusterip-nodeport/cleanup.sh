#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-06-services and all resources within it..."
kubectl delete namespace lab-06-services --ignore-not-found=true
echo "Done."
