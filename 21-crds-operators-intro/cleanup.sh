#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-21-crds (removes Widget resources)..."
kubectl delete namespace lab-21-crds --ignore-not-found=true

echo "Deleting Widget CRD..."
kubectl delete crd widgets.lab.example.com --ignore-not-found=true

echo "Done."
