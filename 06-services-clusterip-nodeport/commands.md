# 06 — Commands

Run in order. Read the output at each step.

---

## 1. Apply all manifests

```bash
kubectl create namespace lab-06-services
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service-clusterip.yaml
kubectl apply -f manifests/service-nodeport.yaml
kubectl get pods -n lab-06-services
```

---

## 2. Inspect the Services

```bash
kubectl get services -n lab-06-services
```

> What is the CLUSTER-IP for nginx-clusterip? What is the port for nginx-nodeport?

---

## 3. Inspect the ClusterIP endpoints

```bash
kubectl get endpoints -n lab-06-services
```

```bash
kubectl describe service nginx-clusterip -n lab-06-services
```

> How many endpoints are listed? Each IP:port maps to one pod. Cross-reference with pod IPs.

---

## 4. Get pod IPs to cross-reference

```bash
kubectl get pods -n lab-06-services -o wide
```

> Do the pod IPs match the endpoint addresses from the previous step?

---

## 5. Access the ClusterIP from inside the cluster

```bash
# Run a temporary busybox pod to curl the ClusterIP
kubectl run curl-test --image=busybox:1.36 --rm -it --restart=Never -n lab-06-services -- sh
```

Inside the shell:
```sh
wget -qO- nginx-clusterip
exit
```

> What does the response look like? Try `wget -qO- <CLUSTER-IP>` using the actual IP too.

---

## 6. Access the NodePort from your host

First, get the kind node IP:

```bash
kubectl get nodes -o wide
```

```bash
# Curl the NodePort using the internal node IP
curl http://<NODE-IP>:30080
```

> Note: On some kind setups, the node IP may not be reachable from your host. If this fails, note it in notes.md and explain why (kind containers are on an internal Docker network).

---

## 7. Apply the broken selector Service

```bash
kubectl apply -f broken/service-bad-selector.yaml
kubectl get endpoints nginx-broken -n lab-06-services
```

> How many endpoints does the broken service have?

---

## 8. Diagnose the problem

```bash
kubectl describe service nginx-broken -n lab-06-services
kubectl get pods -n lab-06-services --show-labels
```

> Compare the service selector to the pod labels. Can you spot the difference?

---

## 9. Apply the fixed Service

```bash
kubectl apply -f fixed/service-fixed-selector.yaml
kubectl get endpoints nginx-broken -n lab-06-services
```

> Did endpoints populate after the fix?

---

## 10. Delete one pod and watch its IP change

```bash
kubectl get pods -n lab-06-services -o wide
kubectl delete pod <any-pod-name> -n lab-06-services
kubectl get pods -n lab-06-services -o wide
```

```bash
kubectl get endpoints nginx-clusterip -n lab-06-services
```

> Did the Service endpoint update to reflect the new pod IP? How does this demonstrate the value of a Service?

---

## 11. Clean up

```bash
./cleanup.sh
```
