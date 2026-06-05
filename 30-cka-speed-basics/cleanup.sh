#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning up Lab 30 — cka-speed-basics..."

kubectl delete namespace speed-01 --ignore-not-found=true

echo "Removing generated files..."
rm -f /tmp/preview-pod.yaml
rm -f /tmp/env-pod.yaml

echo "Cleanup complete."
