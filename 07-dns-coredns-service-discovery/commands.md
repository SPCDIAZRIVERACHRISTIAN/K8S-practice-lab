# 07 — Commands

Run in order. Read the output at each step.

---

## 1. Create the namespaces and apply manifests

```bash
kubectl create namespace lab-07-backend
kubectl create namespace lab-07-dns
kubectl apply -f manifests/backend-deployment.yaml
kubectl apply -f manifests/backend-service.yaml
kubectl apply -f manifests/frontend-pod.yaml
```

```bash
kubectl get pods -n lab-07-backend
kubectl get pods -n lab-07-dns
kubectl get service -n lab-07-backend
```

---

## 2. Exec into the frontend pod

```bash
kubectl exec -it frontend -n lab-07-dns -- sh
```

You are now inside the busybox container in the `lab-07-dns` namespace. Keep this shell open for steps 3–8.

---

## 3. Try the short DNS name (same namespace only)

Inside the frontend pod:

```sh
wget -qO- backend
```

> Does this work? What error do you get? The short name `backend` resolves only within the same namespace. The frontend is in `lab-07-dns`, but the service is in `lab-07-backend`.

---

## 4. Try the service.namespace form

Inside the frontend pod:

```sh
wget -qO- backend.lab-07-backend
```

> Does this resolve? In Kubernetes DNS, `service.namespace` is a valid search domain and should resolve to the service. Write down what you observe.

---

## 5. Try the full FQDN

Inside the frontend pod:

```sh
wget -qO- backend.lab-07-backend.svc.cluster.local
```

> This is the fully qualified domain name. It is the most explicit and most reliable form. Does it return nginx's default page?

---

## 6. Use nslookup to inspect DNS resolution

Inside the frontend pod:

```sh
nslookup backend.lab-07-backend.svc.cluster.local
```

```sh
nslookup backend.lab-07-backend
```

> What IP address does the DNS name resolve to? Is it the ClusterIP of the backend service?

---

## 7. Inspect /etc/resolv.conf inside the pod

Inside the frontend pod:

```sh
cat /etc/resolv.conf
```

> What is the `search` domain listed? What is the `nameserver` IP? Exit the shell when done.

```sh
exit
```

---

## 8. Find the nameserver IP — it is CoreDNS

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get service kube-dns -n kube-system
```

> Compare the `kube-dns` Service ClusterIP to the `nameserver` you saw in `/etc/resolv.conf`. They should match.

---

## 9. Inspect CoreDNS configuration

```bash
kubectl get configmap coredns -n kube-system -o yaml
```

> Look at the `Corefile` section. What is the cluster domain? What plugins are enabled?

---

## 10. View CoreDNS logs

```bash
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=20
```

> Do you see DNS queries logged? (CoreDNS may not log queries by default — that is normal.)

---

## 11. Test DNS for a service in the same namespace (control case)

Create a test service in `lab-07-dns` to confirm short-name DNS works within a namespace:

```bash
kubectl run test-svc --image=nginx:stable --expose --port=80 -n lab-07-dns
kubectl exec -it frontend -n lab-07-dns -- wget -qO- test-svc
```

> Does the short name `test-svc` resolve now that both pods are in the same namespace?

---

## 12. Clean up

```bash
./cleanup.sh
```
