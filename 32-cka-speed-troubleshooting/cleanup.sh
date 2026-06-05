#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning up Lab 32 — cka-speed-troubleshooting..."

kubectl delete namespace speed-32 --ignore-not-found=true

echo "Cleanup complete."
