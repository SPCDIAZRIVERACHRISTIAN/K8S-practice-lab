#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-15-volumes and all resources within it..."
kubectl delete namespace lab-15-volumes --ignore-not-found=true

echo "Cleaning up hostPath directory from kind nodes..."
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  docker exec "$node" rm -rf /tmp/lab-15-hostpath 2>/dev/null && \
    echo "  Removed /tmp/lab-15-hostpath from node $node" || \
    echo "  /tmp/lab-15-hostpath not found on node $node (OK)"
done

echo "Done."
