# Commands to Practice

Run these in order. Do not skip ahead.

---

## 1. Create the cluster

```bash
kind create cluster --config kind-config.yaml
```

## 2. Verify the cluster exists

```bash
kind get clusters
```

## 3. Check cluster info

```bash
kubectl cluster-info --context kind-my-first-cluster
```

## 4. List all nodes

```bash
kubectl get nodes
```

## 5. List nodes with more detail (IP, OS, roles)

```bash
kubectl get nodes -o wide
```

## 6. Describe a specific node

```bash
# Replace <node-name> with one of the names from kubectl get nodes
kubectl describe node <node-name>
```

> Tip: run `kubectl describe node` on the control-plane node and then on a worker.
> Notice what sections are different.

## 7. Delete the cluster

```bash
kind delete cluster --name my-first-cluster
```

## 8. Confirm it is gone

```bash
kind get clusters
```

---

Once you can run all of these without looking them up, move to `01-pods`.
