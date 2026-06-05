#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-04-config and all resources within it..."
kubectl delete namespace lab-04-config --ignore-not-found=true
echo "Done."
