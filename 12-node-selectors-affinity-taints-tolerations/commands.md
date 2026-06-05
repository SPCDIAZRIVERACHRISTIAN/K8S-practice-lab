# 12 — Commands

This lab mixes manifest applies with imperative kubectl commands to label and taint nodes. Follow the order carefully.

---

## 1. Create the namespace and get node names

```bash
kubectl create namespace lab-12-scheduling
kubectl get nodes
```

> Note the names of your two worker nodes. You will use them in the commands below.
> Replace `<worker-1>` and `<worker-2>` with actual node names throughout this lab.

---

## 2. Inspect the control-plane taint

```bash
kubectl describe node <control-plane-node-name> | grep -A3 Taints
```

> What taint does the control-plane have? What does `NoSchedule` mean?

---

## 3. Apply nodeSelector pod BEFORE labeling the node

```bash
kubectl apply -f manifests/pod-nodeselector.yaml
kubectl get pod pod-nodeselector -n lab-12-scheduling
```

> What status does the pod show? It cannot schedule yet because no node has `disktype=ssd`.

---

## 4. Describe the pending pod

```bash
kubectl describe pod pod-nodeselector -n lab-12-scheduling
```

> Read the Events section. What message explains why it is Pending?

---

## 5. Label a worker node

```bash
kubectl label node <worker-1> disktype=ssd
kubectl get node <worker-1> --show-labels
```

> Confirm the label was applied. Watch the pod status:

```bash
kubectl get pod pod-nodeselector -n lab-12-scheduling
```

> Did the pod schedule? Which node did it land on?

---

## 6. Verify pod placement

```bash
kubectl get pod pod-nodeselector -n lab-12-scheduling -o wide
```

> Is it on the node you labeled?

---

## 7. Apply required node affinity

```bash
kubectl apply -f manifests/pod-node-affinity.yaml
kubectl get pod pod-node-affinity -n lab-12-scheduling -o wide
```

> Did it also land on the labeled node?

---

## 8. Apply preferred node affinity

```bash
kubectl apply -f manifests/pod-preferred-affinity.yaml
kubectl get pod pod-preferred-affinity -n lab-12-scheduling -o wide
```

> Did it also land on the labeled node? Delete the label and observe:

```bash
kubectl label node <worker-1> disktype-
kubectl delete pod pod-preferred-affinity -n lab-12-scheduling
kubectl apply -f manifests/pod-preferred-affinity.yaml
kubectl get pod pod-preferred-affinity -n lab-12-scheduling -o wide
```

> Where does the preferred affinity pod go when the preferred node label is gone?

---

## 9. Apply a taint to a worker node

```bash
kubectl taint node <worker-2> dedicated=special:NoSchedule
kubectl describe node <worker-2> | grep -A3 Taints
```

> What does the taint look like?

---

## 10. Deploy pods WITHOUT a toleration

```bash
kubectl run no-toleration --image=nginx:stable -n lab-12-scheduling
kubectl get pod no-toleration -n lab-12-scheduling
kubectl describe pod no-toleration -n lab-12-scheduling
```

> Does the pod schedule on `<worker-2>`? What does the scheduler event say?

---

## 11. Apply a pod WITH the matching toleration

```bash
kubectl apply -f manifests/pod-with-toleration.yaml
kubectl get pod pod-with-toleration -n lab-12-scheduling -o wide
```

> Is the toleration pod allowed to schedule on the tainted node?

---

## 12. Remove the taint from the node

```bash
kubectl taint node <worker-2> dedicated=special:NoSchedule-
kubectl describe node <worker-2> | grep -A3 Taints
```

> The `-` at the end removes the taint. Verify it is gone.

---

## 13. Remove the node label

```bash
kubectl label node <worker-1> disktype-
```

---

## 14. Clean up

```bash
./cleanup.sh
```
