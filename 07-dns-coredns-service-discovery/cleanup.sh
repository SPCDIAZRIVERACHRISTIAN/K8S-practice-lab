#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-07-backend..."
kubectl delete namespace lab-07-backend --ignore-not-found=true

echo "Deleting namespace lab-07-dns..."
kubectl delete namespace lab-07-dns --ignore-not-found=true

echo "Done."
