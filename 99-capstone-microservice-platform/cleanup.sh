#!/usr/bin/env bash
set -euo pipefail

echo "Uncordoning nodes if cordoned during the lab..."
kubectl uncordon kind-worker 2>/dev/null || true
kubectl uncordon kind-worker2 2>/dev/null || true

echo "Scaling down StatefulSet to release PVCs..."
kubectl scale statefulset db --replicas=0 -n capstone 2>/dev/null || true
kubectl wait --for=delete pod -l app=db -n capstone --timeout=60s 2>/dev/null || true

echo "Deleting StatefulSet PVCs..."
kubectl delete pvc -n capstone -l app=db --ignore-not-found=true

echo "Deleting main capstone namespace..."
kubectl delete namespace capstone --ignore-not-found=true

echo "Deleting Kustomize overlay namespaces..."
kubectl delete namespace capstone-dev --ignore-not-found=true
kubectl delete namespace capstone-prod --ignore-not-found=true

echo "Removing etcd snapshot if present..."
ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$ETCD_POD" ]; then
  kubectl exec -n kube-system "$ETCD_POD" -- \
    rm -f /tmp/capstone-backup.db 2>/dev/null || true
fi

echo "Done."
