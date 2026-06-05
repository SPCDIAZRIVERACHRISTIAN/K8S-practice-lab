#!/usr/bin/env bash
set -euo pipefail

echo "Uncordoning nodes if cordoned..."
kubectl uncordon kind-worker 2>/dev/null || true
kubectl uncordon kind-worker2 2>/dev/null || true

echo "Removing exam labels from nodes..."
kubectl label node kind-worker zone- 2>/dev/null || true

echo "Deleting StatefulSet PVCs..."
kubectl scale statefulset cache --replicas=0 -n exam-02 2>/dev/null || true
kubectl wait --for=delete pod -l app=cache -n exam-02 --timeout=60s 2>/dev/null || true
kubectl delete pvc -n exam-02 -l app=cache --ignore-not-found=true

echo "Deleting exam namespaces..."
kubectl delete namespace exam-02 --ignore-not-found=true
kubectl delete namespace exam-02-net --ignore-not-found=true

echo "Removing cluster-scoped RBAC resources..."
kubectl delete clusterrole cluster-reader --ignore-not-found=true
kubectl delete clusterrolebinding cluster-reader-binding --ignore-not-found=true

echo "Removing exam temp files..."
rm -f /tmp/static-pods.txt
rm -f /tmp/cert-expiry.txt
rm -f /tmp/etcd-status.txt
rm -rf /tmp/kustomize-exam

echo "Removing etcd snapshot from etcd container..."
ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$ETCD_POD" ]; then
  kubectl exec -n kube-system "$ETCD_POD" -- \
    rm -f /tmp/etcd-hard-backup.db 2>/dev/null || true
fi

echo "Done."
