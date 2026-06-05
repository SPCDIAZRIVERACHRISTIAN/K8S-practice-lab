#!/usr/bin/env bash
set -euo pipefail

kubectl scale statefulset broken-db --replicas=0 -n lab-28-storage 2>/dev/null || true
kubectl wait --for=delete pod -l app=broken-db -n lab-28-storage --timeout=60s 2>/dev/null || true
kubectl delete pvc -n lab-28-storage -l app=broken-db --ignore-not-found=true
kubectl delete namespace lab-28-storage --ignore-not-found=true
