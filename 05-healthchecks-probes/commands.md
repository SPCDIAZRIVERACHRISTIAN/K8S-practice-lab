# 05 — Commands

Run in order. Read the output at each step.

---

## 1. Create the namespace and apply the working Deployment

```bash
kubectl create namespace lab-05-probes
kubectl apply -f manifests/deployment.yaml
```

---

## 2. Watch the pods become Ready

```bash
kubectl get pods -n lab-05-probes -w
```

> Press Ctrl+C after pods show `1/1 Running`. What does `1/1` mean?

---

## 3. Inspect the probes in the Deployment

```bash
kubectl describe deployment nginx-probes -n lab-05-probes
```

> Find the `Liveness` and `Readiness` sections. What path and port are they checking?

---

## 4. Describe a pod to see probe configuration

```bash
kubectl describe pod -n lab-05-probes -l app=nginx-probes
```

> Look at the `Containers` section. Can you see the probe config? Find `Liveness` and `Readiness`.

---

## 5. Create a ClusterIP Service to see probe impact on endpoints

```bash
kubectl expose deployment nginx-probes --port=80 --target-port=80 -n lab-05-probes
kubectl get endpoints nginx-probes -n lab-05-probes
```

> How many endpoints are listed? Each entry is a pod IP + port that the service will route traffic to.

---

## 6. Apply the broken probe Deployment

```bash
kubectl apply -f broken/deployment-bad-probe.yaml
```

```bash
kubectl get pods -n lab-05-probes -w
```

> Watch the bad-probes pods. Do they reach `1/1 Running` or stay at `0/1 Running`?

---

## 7. Inspect the broken pods

```bash
kubectl get pods -n lab-05-probes
kubectl describe pod -n lab-05-probes -l app=nginx-bad-probes
```

> In the Events section: what events are being generated? Look at the RESTARTS column after a few minutes.

---

## 8. Observe the liveness probe killing the container

Wait 2-3 minutes, then:

```bash
kubectl get pods -n lab-05-probes
```

> Check the RESTARTS column for the `nginx-bad-probes` pods. Is the number increasing?

---

## 9. Check endpoints for the bad-probes deployment

```bash
kubectl expose deployment nginx-bad-probes --port=80 --target-port=80 -n lab-05-probes --name=nginx-bad-probes-svc
kubectl get endpoints nginx-bad-probes-svc -n lab-05-probes
```

> Are there any endpoints listed? Compare to the working deployment's endpoints.

---

## 10. Fix the probes

Edit `broken/deployment-bad-probe.yaml`:
- Change the readiness probe path from `/healthz` to `/`
- Change the liveness probe port from `9090` to `80`

Then reapply:

```bash
kubectl apply -f broken/deployment-bad-probe.yaml
kubectl get pods -n lab-05-probes -w
```

> Do the pods become `1/1 Running` after the fix?

---

## 11. Verify endpoints after the fix

```bash
kubectl get endpoints nginx-bad-probes-svc -n lab-05-probes
```

> Are there endpoints now?

---

## 12. Clean up

```bash
./cleanup.sh
```
