#!/usr/bin/env bash
set -euo pipefail

echo "Scaling StatefulSet to 0 to release PVCs cleanly..."
kubectl scale statefulset web --replicas=0 -n lab-17-statefulsets 2>/dev/null || true

echo "Waiting for pods to terminate..."
kubectl wait --for=delete pod -l app=web -n lab-17-statefulsets --timeout=60s 2>/dev/null || true

echo "Deleting PVCs created by the StatefulSet..."
kubectl delete pvc -n lab-17-statefulsets -l app=web --ignore-not-found=true

echo "Deleting namespace lab-17-statefulsets..."
kubectl delete namespace lab-17-statefulsets --ignore-not-found=true

echo "Done."
