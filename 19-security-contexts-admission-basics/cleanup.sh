#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-19-security..."
kubectl delete namespace lab-19-security --ignore-not-found=true

echo "Deleting namespace lab-19-baseline..."
kubectl delete namespace lab-19-baseline --ignore-not-found=true

echo "Done."
