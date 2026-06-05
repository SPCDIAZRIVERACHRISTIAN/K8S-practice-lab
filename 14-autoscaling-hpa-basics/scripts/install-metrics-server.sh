#!/usr/bin/env bash
set -euo pipefail

echo "Installing metrics-server for kind..."
echo "Source: https://github.com/kubernetes-sigs/metrics-server"
echo ""

# Apply the official release
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# kind uses self-signed certificates for kubelet — patch metrics-server to skip TLS verification
echo "Patching metrics-server for kind compatibility (--kubelet-insecure-tls)..."
kubectl patch deployment metrics-server -n kube-system \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo ""
echo "Waiting for metrics-server to be ready..."
kubectl rollout status deployment metrics-server -n kube-system --timeout=90s

echo ""
echo "metrics-server is ready."
echo "Wait 30 seconds, then test with: kubectl top nodes"
