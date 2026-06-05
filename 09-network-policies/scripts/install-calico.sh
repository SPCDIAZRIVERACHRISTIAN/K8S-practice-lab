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

# Install the Tigera operator (apply is idempotent; create would fail on re-run)
echo "Applying Tigera operator..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml

# Install Calico custom resources
echo "Applying Calico installation CR..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml

echo ""
echo "Waiting for calico-node pods to be created (this may take up to 60s)..."
# kubectl wait will error immediately if no pods match the selector, so we poll
# until at least one pod exists before handing off to kubectl wait.
for i in $(seq 1 30); do
  COUNT=$(kubectl get pods -n calico-system -l k8s-app=calico-node --no-headers 2>/dev/null | wc -l)
  if [ "$COUNT" -gt 0 ]; then
    break
  fi
  echo "  No calico-node pods yet, retrying in 5s... ($i/30)"
  sleep 5
done

echo "calico-node pods found. Waiting for Ready condition (up to 3 minutes)..."
kubectl wait --namespace calico-system \
  --for=condition=ready pod \
  --selector=k8s-app=calico-node \
  --timeout=180s

echo ""
echo "Calico is ready."
echo "Run: kubectl get pods -n calico-system"
