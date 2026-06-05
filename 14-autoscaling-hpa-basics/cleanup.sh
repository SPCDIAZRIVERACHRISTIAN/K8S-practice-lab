#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace lab-14-autoscaling and all resources within it..."
kubectl delete namespace lab-14-autoscaling --ignore-not-found=true

echo ""
echo "NOTE: metrics-server was installed cluster-wide in kube-system."
echo "It will remain available for future labs (lab 29 uses kubectl top)."
echo "To remove it manually: kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
echo ""
echo "Done."
