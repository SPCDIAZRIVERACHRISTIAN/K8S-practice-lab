# 09 — Commands

This lab uses the `netpol-lab` cluster, not the main `kind` cluster. Confirm your context before running any command.

---

## 1. Create the cluster and install Calico

```bash
kind create cluster --config calico-kind-config.yaml
kubectl config use-context kind-netpol-lab
./scripts/install-calico.sh
```

---

## 2. Verify Calico is running

```bash
kubectl get pods -n calico-system
kubectl get nodes
```

> All nodes should show `Ready`. Calico must be fully running before applying workloads.

---

## 3. Apply workloads

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/backend-deployment.yaml
kubectl apply -f manifests/backend-service.yaml
kubectl apply -f manifests/frontend-pod.yaml
kubectl apply -f manifests/other-pod.yaml
```

```bash
kubectl get pods -n lab-09-netpol -o wide
kubectl get service backend -n lab-09-netpol
```

---

## 4. Baseline: test connectivity BEFORE any NetworkPolicy

From frontend-pod:

```bash
kubectl exec -it frontend-pod -n lab-09-netpol -- wget -qO- --timeout=3 backend
```

From other-pod:

```bash
kubectl exec -it other-pod -n lab-09-netpol -- wget -qO- --timeout=3 backend
```

> Both should succeed at this point. Write down the results before applying any policy.

---

## 5. Apply deny-all ingress to backend

```bash
kubectl apply -f manifests/netpol-deny-all-ingress.yaml
kubectl get networkpolicy -n lab-09-netpol
```

---

## 6. Test connectivity after deny-all

From frontend-pod:

```bash
kubectl exec -it frontend-pod -n lab-09-netpol -- wget -qO- --timeout=3 backend
```

From other-pod:

```bash
kubectl exec -it other-pod -n lab-09-netpol -- wget -qO- --timeout=3 backend
```

> Both should now fail (timeout or connection refused). Write down the results.

---

## 7. Apply the allow-frontend policy

```bash
kubectl apply -f manifests/netpol-allow-frontend.yaml
kubectl get networkpolicy -n lab-09-netpol
```

---

## 8. Test connectivity after allow-frontend

From frontend-pod:

```bash
kubectl exec -it frontend-pod -n lab-09-netpol -- wget -qO- --timeout=3 backend
```

From other-pod:

```bash
kubectl exec -it other-pod -n lab-09-netpol -- wget -qO- --timeout=3 backend
```

> frontend-pod should succeed. other-pod should still fail. Record both results.

---

## 9. Inspect the NetworkPolicy objects

```bash
kubectl describe networkpolicy deny-all-ingress-to-backend -n lab-09-netpol
kubectl describe networkpolicy allow-frontend-to-backend -n lab-09-netpol
```

> Read the `Spec` section carefully. What is each policy selecting? What is each policy allowing or denying?

---

## 10. Try connecting using the pod IP directly (bypass the service)

```bash
BACKEND_IP=$(kubectl get pod -n lab-09-netpol -l app=backend -o jsonpath='{.items[0].status.podIP}')
echo "Backend pod IP: $BACKEND_IP"

kubectl exec -it frontend-pod -n lab-09-netpol -- wget -qO- --timeout=3 "$BACKEND_IP"
kubectl exec -it other-pod -n lab-09-netpol -- wget -qO- --timeout=3 "$BACKEND_IP"
```

> Does the policy enforce on direct pod IP, or only through the Service? This is an important distinction.

---

## 11. Delete only the allow policy and re-test

```bash
kubectl delete networkpolicy allow-frontend-to-backend -n lab-09-netpol
kubectl exec -it frontend-pod -n lab-09-netpol -- wget -qO- --timeout=3 backend
```

> Is the deny-all policy still enforced even without the allow policy?

---

## 12. Clean up — deletes the netpol-lab cluster

```bash
./cleanup.sh
```

After cleanup, switch back to your main cluster:

```bash
kubectl config use-context kind-kind
```
