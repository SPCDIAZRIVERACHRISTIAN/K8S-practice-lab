#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-08-ingress..."
kubectl delete namespace lab-08-ingress --ignore-not-found=true

echo "Deleting ingress-nginx namespace..."
kubectl delete namespace ingress-nginx --ignore-not-found=true

echo "Deleting ingress-nginx cluster-scoped resources..."
kubectl delete clusterrole ingress-nginx --ignore-not-found=true
kubectl delete clusterrolebinding ingress-nginx --ignore-not-found=true
kubectl delete ingressclass nginx --ignore-not-found=true

echo "Done."
