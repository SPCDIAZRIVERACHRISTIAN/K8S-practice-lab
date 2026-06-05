# 14 — Commands

Run in order. Some steps require waiting a few minutes for the HPA to act.

---

## 1. Install metrics-server

```bash
./scripts/install-metrics-server.sh
```

Wait for the script to confirm readiness. Then wait 30 more seconds before continuing.

---

## 2. Verify metrics-server works

```bash
kubectl top nodes
kubectl top pods -A
```

> Do you see CPU and memory values? If you see "metrics not yet available", wait another 30 seconds and retry.

---

## 3. Create the namespace and apply the Deployment

```bash
kubectl create namespace lab-14-autoscaling
kubectl apply -f manifests/deployment.yaml
kubectl get pods -n lab-14-autoscaling
```

---

## 4. Expose the Deployment as a Service (needed for load generator)

```bash
kubectl expose deployment php-apache --port=80 -n lab-14-autoscaling
```

---

## 5. Apply the HPA

```bash
kubectl apply -f manifests/hpa.yaml
kubectl get hpa -n lab-14-autoscaling
```

> What does the TARGETS column show? It may say `<unknown>/50%` at first — wait 30 seconds and recheck. Once metrics-server has collected data it will show the actual CPU utilization.

---

## 6. Describe the HPA

```bash
kubectl describe hpa php-apache-hpa -n lab-14-autoscaling
```

> Look at: `Reference`, `Metrics`, `Min replicas`, `Max replicas`, `Conditions`. What condition says the HPA is ready to scale?

---

## 7. Watch HPA in a second terminal

Open a second terminal and run:

```bash
kubectl get hpa -n lab-14-autoscaling -w
```

Keep this running while you generate load in the next step.

---

## 8. Start the load generator

```bash
kubectl apply -f manifests/load-generator.yaml
```

> In your watching terminal: watch the TARGETS column in `kubectl get hpa`. The current CPU utilization should climb above 50%.

---

## 9. Observe the Deployment scale up

```bash
kubectl get pods -n lab-14-autoscaling
kubectl get deployment php-apache -n lab-14-autoscaling
```

> How many replicas does the Deployment have now? The HPA may take 1–3 minutes to react.

---

## 10. Stop the load generator

```bash
kubectl delete pod load-generator -n lab-14-autoscaling
```

> Continue watching the HPA. How long does it take for CPU to drop and replicas to scale back down? (Scale-down has a 5-minute cooldown by default.)

---

## 11. Observe scale-down

```bash
kubectl get hpa -n lab-14-autoscaling -w
```

> The HPA will scale back to `minReplicas: 1` after the scale-down stabilization window passes.

---

## 12. Break: remove CPU requests and observe HPA failure

```bash
kubectl apply -f broken/deployment-no-requests.yaml
```

Wait 60 seconds, then:

```bash
kubectl get hpa -n lab-14-autoscaling
kubectl describe hpa php-apache-hpa -n lab-14-autoscaling
```

> What does the TARGETS column show now? Look at the `Conditions` section in the describe output — what condition message explains the problem?

---

## 13. Fix: restore CPU requests

```bash
kubectl apply -f manifests/deployment.yaml
```

Wait 60 seconds, then verify HPA shows real metrics again:

```bash
kubectl get hpa -n lab-14-autoscaling
```

---

## 14. Clean up

```bash
./cleanup.sh
```
