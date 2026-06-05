#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-05-probes and all resources within it..."
kubectl delete namespace lab-05-probes --ignore-not-found=true
echo "Done."
