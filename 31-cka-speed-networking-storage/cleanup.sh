#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning up Lab 31 — cka-speed-networking-storage..."

kubectl delete namespace speed-31 --ignore-not-found=true

echo "Removing generated files..."
rm -f /tmp/data-pod.yaml

echo "Cleanup complete."
