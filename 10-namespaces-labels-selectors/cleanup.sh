#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-10-team-a..."
kubectl delete namespace lab-10-team-a --ignore-not-found=true

echo "Deleting namespace lab-10-team-b..."
kubectl delete namespace lab-10-team-b --ignore-not-found=true

echo "Done."
