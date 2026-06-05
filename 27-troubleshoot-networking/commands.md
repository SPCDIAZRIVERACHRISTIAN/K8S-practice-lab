# Lab 27 — Commands Walkthrough

## 1. Apply all manifests

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/backend-deployment.yaml
kubectl apply -f manifests/client-pod.yaml
kubectl apply -f broken/service-wrong-selector.yaml
kubectl apply -f broken/service-wrong-port.yaml
kubectl apply -f broken/service-wrong-name-pod.yaml
```

Wait for pods to start:

```bash
kubectl get pods -n lab-27-network --watch
```

Press Ctrl-C when both backend pods and the client pod are Running.

> Observation question: Does the wrong-dns-client pod appear Running even though it will be failing to connect? Why?

---

## 2. Survey all endpoints at once

```bash
kubectl get endpoints -n lab-27-network
```

> Observation questions:
> - Which services show `<none>` in the ENDPOINTS column?
> - Which service has endpoints populated?
> - At this point, do you know *why* backend-svc has no endpoints?

---

## 3. Test connectivity from the client pod

First, try the service that should work (but has a selector typo):

```bash
kubectl exec -it client -n lab-27-network -- wget -qO- http://backend-svc --timeout=5
```

Then try the service with the wrong port:

```bash
kubectl exec -it client -n lab-27-network -- wget -qO- http://backend-port-svc --timeout=5
```

> Observation questions:
> - What error does backend-svc return? Is it a timeout or a refused connection?
> - What error does backend-port-svc return?
> - Are the two error types different? What does each tell you?

---

## 4. Diagnose the selector typo — compare labels to selector

Check what labels the running backend pods have:

```bash
kubectl get pods -n lab-27-network --show-labels
```

Check what selector the broken service is using:

```bash
kubectl describe svc backend-svc -n lab-27-network | grep -i selector
```

> Observation questions:
> - What is the selector value in the service?
> - What is the label on the backend pods?
> - Can you see the typo now?

---

## 5. Fix the selector typo

Fix the selector using `kubectl patch` (no deletion required):

```bash
kubectl patch svc backend-svc -n lab-27-network \
  -p '{"spec":{"selector":{"app":"backend"}}}'
```

Verify the fix:

```bash
kubectl get endpoints backend-svc -n lab-27-network
```

> Observation questions:
> - How quickly did the endpoints appear after the patch?
> - How many endpoint addresses are listed? Does that match the number of backend replicas?

---

## 6. Re-test connectivity through the fixed service

```bash
kubectl exec -it client -n lab-27-network -- wget -qO- http://backend-svc --timeout=5
```

> Observation question: What does nginx return when a connection succeeds?

---

## 7. Test the wrong-port service

```bash
kubectl exec -it client -n lab-27-network -- wget -qO- http://backend-port-svc --timeout=5
```

> Observation questions:
> - Is the error the same as before (timeout) or different (connection refused)?
> - Why is a connection refused on port 9090 different from no endpoints?

---

## 8. Diagnose the wrong targetPort

```bash
kubectl describe svc backend-port-svc -n lab-27-network
```

Look at the Port section:

```
Port:       <unset>  80/TCP
TargetPort: 9090/TCP
Endpoints:  <pod-ip>:9090, <pod-ip>:9090
```

Notice that endpoints are populated (selector is correct) but the targetPort points to 9090, which nothing is listening on.

```bash
# Confirm nginx listens on 80, not 9090
kubectl exec -it client -n lab-27-network -- wget -qO- http://backend-svc:80 --timeout=5
```

> Observation questions:
> - What is listed in the Endpoints section of backend-port-svc describe output?
> - Even though endpoints are listed, why does the connection fail?
> - What field would you change to fix this service?

---

## 9. Fix the wrong targetPort

```bash
kubectl patch svc backend-port-svc -n lab-27-network \
  -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
```

Verify:

```bash
kubectl get endpoints backend-port-svc -n lab-27-network
kubectl exec -it client -n lab-27-network -- wget -qO- http://backend-port-svc --timeout=5
```

---

## 10. Diagnose the DNS name failure

Check the logs of the wrong-dns-client pod:

```bash
kubectl logs wrong-dns-client -n lab-27-network
```

The pod is trying to reach `http://backend` — but the service is named `backend-svc`.

> Observation question: What error message do the logs show? Does it mention DNS or connection refused?

Now exec into the client pod and test DNS resolution directly:

```bash
kubectl exec -it client -n lab-27-network -- nslookup backend-svc
```

```bash
kubectl exec -it client -n lab-27-network -- nslookup backend
```

```bash
kubectl exec -it client -n lab-27-network -- nslookup backend-svc.lab-27-network.svc.cluster.local
```

> Observation questions:
> - Which of the three nslookup commands succeed?
> - Which name form resolves correctly from within the same namespace?
> - What FQDN does the first command resolve to?

---

## 11. The three DNS name forms inside a pod

From within a pod in namespace `lab-27-network`, the following three forms all resolve to the same service (when the service exists):

```
backend-svc                                       # short name (same namespace only)
backend-svc.lab-27-network                        # service.namespace
backend-svc.lab-27-network.svc.cluster.local      # FQDN
```

Test each form from the client pod:

```bash
kubectl exec -it client -n lab-27-network -- nslookup backend-svc
kubectl exec -it client -n lab-27-network -- nslookup backend-svc.lab-27-network
kubectl exec -it client -n lab-27-network -- nslookup backend-svc.lab-27-network.svc.cluster.local
```

> Observation questions:
> - Do all three forms return the same IP address?
> - If the client pod were in a different namespace (say, `default`), which forms would still work?
> - What would happen if you tried `nslookup backend-svc` from the `default` namespace?

---

## 12. Fix the wrong-dns-client (conceptual)

The wrong-dns-client pod uses a hardcoded URL `http://backend`. The fix requires changing the pod spec — either to `http://backend-svc` or to the FQDN. Since pods are immutable, you would delete and recreate it with the correct URL.

> Final observation questions:
> - What are the three networking problems you diagnosed in this lab?
> - For each problem, what was the first command that revealed the root cause?
> - How do you fix a service selector without recreating the service?
