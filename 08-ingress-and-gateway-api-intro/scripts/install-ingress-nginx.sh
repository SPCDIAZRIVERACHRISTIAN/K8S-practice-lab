#!/usr/bin/env bash
set -euo pipefail

echo "Installing ingress-nginx for kind..."
echo "Source: https://github.com/kubernetes/ingress-nginx"
echo ""

# Official ingress-nginx deployment manifest for kind
MANIFEST_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

kubectl apply -f "$MANIFEST_URL"

echo ""
echo "Waiting for ingress-nginx controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo ""
echo "ingress-nginx is ready."
echo "Run: kubectl get pods -n ingress-nginx"
