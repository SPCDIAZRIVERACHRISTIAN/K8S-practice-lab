#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-16-storage and all resources within it..."
kubectl delete namespace lab-16-storage --ignore-not-found=true

echo ""
echo "Waiting for PVCs to terminate and PVs to be reclaimed..."
sleep 5

echo "Checking for leftover PVs from this lab..."
kubectl get pv 2>/dev/null | grep "lab-16-storage" || echo "No lab-16 PVs remaining."

echo "Done."
