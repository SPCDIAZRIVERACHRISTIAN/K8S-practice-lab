# 00 — Commands

Run in order. After each section, read the output before moving on. Do not skip ahead.

---

## 1. Create the cluster

```bash
kind create cluster --config kind-config.yaml
```

Watch the output as kind runs. It pulls images, creates Docker containers, and sets up kubectl.

> What context name does it print at the end? Write it down.

---

## 2. Confirm the cluster and context exist

```bash
kind get clusters
```

```bash
kubectl config current-context
```

```bash
kubectl config get-contexts
```

> What is the difference between what `kind get clusters` shows and what `kubectl config current-context` shows? These two commands answer different questions.

---

## 3. Get the cluster endpoint

```bash
kubectl cluster-info --context kind-my-first-cluster
```

> Copy the API server URL from the output. Open it in a browser. What does the response say? Write it down. You will explain it in `notes.md`.

---

## 4. List the nodes

```bash
kubectl get nodes
```

```bash
kubectl get nodes -o wide
```

> How many nodes are there? What are their roles? What extra information does `-o wide` give you that the first command does not?

---

## 5. Describe the control-plane node

```bash
# Use the actual node name from kubectl get nodes
kubectl describe node <control-plane-node-name>
```

Scroll through the full output and look for these sections:
- `Taints`
- `Capacity` and `Allocatable`
- `Conditions`
- `Non-terminated Pods`

> Does the control-plane node have a taint? Write down what the taint says.

---

## 6. Describe a worker node

```bash
kubectl describe node <worker-node-name>
```

> Compare it to the control-plane node. What is different? Does the worker have a taint? Which pods are scheduled on it?

---

## 7. List all system pods

```bash
kubectl get pods -A
```

```bash
kubectl get pods -n kube-system -o wide
```

> These pods run Kubernetes itself. Notice the `NODE` column. Where is each pod scheduled? Go to `notes.md` and write down what you think each pod name does.

---

## 8. Describe a system pod

```bash
# Pick one — for example, kube-apiserver or coredns
kubectl describe pod -n kube-system <pod-name>
```

> Look at: `Node`, `Status`, `Containers`, `Command`, `Volumes`, `Events`.

---

## 9. See the kind nodes as Docker containers

```bash
docker ps
```

> Each container in this list is a Kubernetes node. Match the container names to the node names from `kubectl get nodes`.

---

## 10. Delete the cluster and observe what happens to kubectl

```bash
kind delete cluster --name my-first-cluster
```

```bash
kubectl config get-contexts
```

```bash
kind get clusters
```

> After deletion: is the kubectl context still there? Is the cluster still listed?

---

## 11. Recreate the cluster

```bash
kind create cluster --config kind-config.yaml
```

> Does it come back exactly the same? What changed? What was preserved?

---

## 12. Clean up when done with the lab

```bash
./cleanup.sh
```
