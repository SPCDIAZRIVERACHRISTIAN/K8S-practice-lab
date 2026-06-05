# 08 — Commands

Run in order. Read the output at each step.

---

## 1. Install the ingress-nginx controller

```bash
./scripts/install-ingress-nginx.sh
```

Wait for it to print "ingress-nginx is ready." before continuing.

---

## 2. Verify the controller is running

```bash
kubectl get pods -n ingress-nginx
kubectl get service -n ingress-nginx
```

> What type is the ingress-nginx-controller service? What ports does it expose?

---

## 3. Create the namespace and apply app manifests

```bash
kubectl create namespace lab-08-ingress
kubectl apply -f manifests/deployment-frontend.yaml
kubectl apply -f manifests/deployment-backend.yaml
kubectl apply -f manifests/services.yaml
kubectl apply -f manifests/ingress.yaml
```

```bash
kubectl get pods -n lab-08-ingress
kubectl get services -n lab-08-ingress
kubectl get ingress -n lab-08-ingress
```

---

## 4. Inspect the Ingress resource

```bash
kubectl describe ingress lab-ingress -n lab-08-ingress
```

> Look at the `Rules` section. What path routes to which backend service and port?

---

## 5. Access the frontend via Ingress

The ingress-nginx controller in kind listens on localhost:80 and localhost:443 (if kind was configured with extraPortMappings). Try:

```bash
curl http://localhost/
```

> Do you get the nginx default page? If not, check if your kind cluster was created with the port mappings required for ingress-nginx.

---

## 6. Access the backend path

```bash
curl http://localhost/api
```

> Do you get a response? (Both paths return nginx default pages here since both backends are plain nginx — the routing is the thing being tested, not the content.)

---

## 7. Apply the broken Ingress

```bash
kubectl apply -f broken/ingress-wrong-port.yaml
```

```bash
curl http://localhost/api
```

> What HTTP status code do you get now? A `503 Service Unavailable` means the controller has no reachable upstream for that path.

---

## 8. Diagnose using kubectl describe

```bash
kubectl describe ingress lab-ingress -n lab-08-ingress
```

> Look at the Rules section and the Events section. Can you see the wrong port in the rule?

---

## 9. Check the service port to confirm the mismatch

```bash
kubectl get service backend-svc -n lab-08-ingress
```

> What port does `backend-svc` actually expose? Compare it to the port in the Ingress rule.

---

## 10. Apply the fix

```bash
kubectl apply -f fixed/ingress-correct-port.yaml
curl http://localhost/api
```

> Does the `/api` path work again?

---

## 11. Clean up

```bash
./cleanup.sh
```
