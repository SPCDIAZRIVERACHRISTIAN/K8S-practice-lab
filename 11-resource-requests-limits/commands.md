# 11 — Commands

Run in order. Read the output at each step.

---

## 1. Create the namespace and apply working pods

```bash
kubectl create namespace lab-11-resources
kubectl apply -f manifests/pod-guaranteed.yaml
kubectl apply -f manifests/pod-burstable.yaml
kubectl apply -f manifests/pod-besteffort.yaml
kubectl get pods -n lab-11-resources
```

---

## 2. Find the QoS class for each pod

```bash
kubectl describe pod pod-guaranteed -n lab-11-resources | grep -i qos
kubectl describe pod pod-burstable -n lab-11-resources | grep -i qos
kubectl describe pod pod-besteffort -n lab-11-resources | grep -i qos
```

> What QoS class does each pod have? Write them down.

---

## 3. Inspect resource configuration in the describe output

```bash
kubectl describe pod pod-guaranteed -n lab-11-resources
```

> Find the `Requests` and `Limits` sections under Containers. What are the values?

---

## 4. View node allocatable resources

```bash
kubectl describe node <worker-node-name>
```

> Find the `Allocatable` section. How much CPU and memory is available on that node? Compare to what `pod-guaranteed` is requesting.

---

## 5. Check current resource usage (if metrics-server is installed)

```bash
kubectl top pods -n lab-11-resources
kubectl top nodes
```

> Note: if metrics-server is not installed, this returns an error. That is fine — install it in lab 14.

---

## 6. Apply the unschedulable pod

```bash
kubectl apply -f broken/pod-unschedulable.yaml
kubectl get pod pod-unschedulable -n lab-11-resources
```

> What is the pod status?

---

## 7. Diagnose why the pod is unschedulable

```bash
kubectl describe pod pod-unschedulable -n lab-11-resources
```

> Scroll to the `Events` section at the bottom. What message appears? Which scheduler event explains the failure?

---

## 8. Check node capacity to understand the failure

```bash
kubectl get nodes -o custom-columns="NAME:.metadata.name,CPU:.status.allocatable.cpu,MEM:.status.allocatable.memory"
```

> How much memory does the largest node have? Compare it to the 100Gi request.

---

## 9. Apply the OOM pod

```bash
kubectl apply -f broken/pod-oom.yaml
kubectl get pod pod-oom -n lab-11-resources -w
```

> Press Ctrl+C after the pod restarts once. What status does it show?

---

## 10. Confirm OOMKilled

```bash
kubectl describe pod pod-oom -n lab-11-resources
```

> Find the `Last State` section under Containers. What is the reason listed?

---

## 11. Watch the restart count grow

```bash
kubectl get pod pod-oom -n lab-11-resources
```

Wait 2 minutes and run it again.

> Is the RESTARTS count increasing? What state does the pod enter after multiple restarts?

---

## 12. Delete the unschedulable pod

```bash
kubectl delete pod pod-unschedulable -n lab-11-resources
```

---

## 13. Clean up

```bash
./cleanup.sh
```
