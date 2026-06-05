#!/usr/bin/env bash
set -euo pipefail

echo "Installing Calico CNI on the netpol-lab cluster..."
echo "Source: https://docs.tigera.io/calico/latest/getting-started/kubernetes/kind"
echo ""

# Verify context is pointed at netpol-lab
CURRENT_CONTEXT=$(kubectl config current-context)
if [[ "$CURRENT_CONTEXT" != "kind-netpol-lab" ]]; then
  echo "WARNING: Current context is '$CURRENT_CONTEXT', expected 'kind-netpol-lab'."
  echo "Switch context with: kubectl config use-context kind-netpol-lab"
  echo "Then rerun this script."
  exit 1
fi

# Install the Tigera operator
echo "Applying Tigera operator..."
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml

# Install Calico custom resources
echo "Applying Calico installation CR..."
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml

echo ""
echo "Waiting for Calico pods to become ready (this may take 2-3 minutes)..."
kubectl wait --namespace calico-system \
  --for=condition=ready pod \
  --selector=k8s-app=calico-node \
  --timeout=180s

echo ""
echo "Calico is ready."
echo "Run: kubectl get pods -n calico-system"
