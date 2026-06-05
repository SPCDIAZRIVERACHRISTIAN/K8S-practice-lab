# Commands — 29 Troubleshoot Cluster Nodes

---

## 1. Set up baseline

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/deployment.yaml
```

```bash
kubectl get pods -n lab-29-nodes -o wide
kubectl get nodes
```

> Which nodes are the 3 pods spread across?

---

## 2. Inspect node details before breaking anything

```bash
kubectl describe node kind-worker | grep -A 10 Taints
kubectl get nodes --show-labels
```

> Are there any existing taints on the worker nodes? What labels are already on them?

---

## 3. Scenario 1 — Taint without toleration

Add a custom taint:

```bash
kubectl taint node kind-worker dedicated=gpu:NoSchedule
```

Apply the pod with no toleration:

```bash
kubectl apply -f broken/01-no-toleration.yaml
kubectl get pod no-toleration-pod -n lab-29-nodes
```

> Is the pod Running or Pending?

```bash
kubectl describe pod no-toleration-pod -n lab-29-nodes | grep -A 10 Events
```

> What is the exact scheduling failure message? Which part mentions the taint?

**Fix A — add a toleration (in-place edit):**

```bash
kubectl patch pod no-toleration-pod -n lab-29-nodes \
  --type=json \
  -p='[{"op":"add","path":"/spec/tolerations","value":[{"key":"dedicated","operator":"Equal","value":"gpu","effect":"NoSchedule"}]}]'
```

> Does an in-place patch on pod tolerations work? (Pods are mostly immutable after creation.)

**Fix B — delete and recreate with toleration:**

```bash
kubectl delete pod no-toleration-pod -n lab-29-nodes
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: no-toleration-pod
  namespace: lab-29-nodes
spec:
  tolerations:
  - key: dedicated
    operator: Equal
    value: gpu
    effect: NoSchedule
  containers:
  - name: nginx
    image: nginx:stable
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
EOF
kubectl get pod no-toleration-pod -n lab-29-nodes -o wide
```

> Which node did the pod schedule on after adding the toleration?

Remove the taint:

```bash
kubectl taint node kind-worker dedicated=gpu:NoSchedule-
```

---

## 4. Scenario 2 — Bad nodeSelector

```bash
kubectl apply -f broken/02-bad-nodeselector.yaml
kubectl describe pod bad-selector-pod -n lab-29-nodes | grep -A 5 Events
```

> What is the exact scheduling failure message for a nodeSelector mismatch?

```bash
kubectl get nodes --show-labels | grep disktype
```

> Do any nodes have the `disktype` label?

**Fix A — add the label to a node:**

```bash
kubectl label node kind-worker disktype=nvme-ultra
kubectl get pod bad-selector-pod -n lab-29-nodes
```

> Does the pod schedule immediately when the label is added? Does it need to be restarted?

Clean up:

```bash
kubectl label node kind-worker disktype-
```

**Fix B — remove the nodeSelector from the pod:**

```bash
kubectl delete pod bad-selector-pod -n lab-29-nodes
# Edit broken/02-bad-nodeselector.yaml: remove the nodeSelector block
kubectl apply -f broken/02-bad-nodeselector.yaml
```

---

## 5. Scenario 3 — Bad node affinity

```bash
kubectl apply -f broken/03-bad-affinity.yaml
kubectl describe pod bad-affinity-pod -n lab-29-nodes | grep -A 10 Events
```

> What is the exact scheduling failure message for affinity mismatch?

```bash
kubectl get nodes -o jsonpath='{.items[*].metadata.name}'
```

> What are the actual node names in the cluster?

**Fix — correct the affinity to an existing node:**

```bash
kubectl delete pod bad-affinity-pod -n lab-29-nodes
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: bad-affinity-pod
  namespace: lab-29-nodes
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
            - kind-worker    # existing node
  containers:
  - name: nginx
    image: nginx:stable
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
EOF
kubectl get pod bad-affinity-pod -n lab-29-nodes -o wide
```

> Which node did the pod land on?

---

## 6. Read node conditions

```bash
kubectl describe node kind-worker | grep -A 20 "^Conditions:"
```

> What conditions exist? What does `Ready=True` mean? What would `MemoryPressure=True` trigger?

```bash
kubectl describe node kind-worker | grep -A 5 "^Capacity:"
kubectl describe node kind-worker | grep -A 5 "^Allocatable:"
```

> What is the difference? How much memory is reserved for the node OS and kubelet?

---

## 7. Find why a pod is Pending — fast triage method

For any Pending pod, this two-command sequence reveals the cause:

```bash
kubectl get pod <name> -n <ns> -o wide         # see which node (or <none>)
kubectl describe pod <name> -n <ns> | tail -20  # read Events at bottom
```

Practice: look at each broken pod's events and match the message to the root cause.

| Message fragment | Root cause |
|-----------------|-----------|
| `didn't match Pod's node affinity/selector` | nodeSelector or required affinity mismatch |
| `had taint {key=value:effect} that the pod didn't tolerate` | Missing toleration |
| `Insufficient cpu` or `Insufficient memory` | Resource request exceeds allocatable |
| `node(s) had untolerated taint {node.kubernetes.io/unschedulable:NoSchedule}` | Node is cordoned |
