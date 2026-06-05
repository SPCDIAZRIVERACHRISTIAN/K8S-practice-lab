#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="my-first-cluster"

echo "Deleting kind cluster: $CLUSTER_NAME"
kind delete cluster --name "$CLUSTER_NAME"
echo "Done. Run 'kind get clusters' to confirm."
