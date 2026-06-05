#!/usr/bin/env bash
set -euo pipefail

echo "Deleting the netpol-lab kind cluster..."
echo "This will NOT affect your main kind cluster (my-first-cluster)."
kind delete cluster --name netpol-lab
echo ""
echo "Done. Switch back to your main cluster if needed:"
echo "  kubectl config use-context kind-my-first-cluster"
