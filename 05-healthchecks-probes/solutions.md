# Solutions — 05 Health Checks and Probes

---

## Three probe types

| Probe | Purpose | On failure |
|-------|---------|-----------|
| `readinessProbe` | Is the container ready to receive traffic? | Remove pod from Service endpoints. Pod stays running. |
| `livenessProbe` | Is the container still alive and functional? | Kill and restart the container. |
| `startupProbe` | Did the container finish starting? | Kill and restart the container (used for slow-starting apps). |

A pod can be `Running` (process is alive) but `0/1` Ready (readiness probe is failing). The container is not killed, but no traffic is routed to it through a Service.

---

## Why `/healthz` causes readiness failure

nginx does not serve a `/healthz` endpoint by default. A request to `/healthz` returns an HTTP 404. HTTP probes fail when the status code is `>= 400`. So the probe consistently fails, and the pod never becomes Ready.

---

## Why port `9090` causes liveness failure

nginx listens on port 80, not 9090. A TCP connection to port 9090 gets a `Connection refused`. This is a liveness probe failure. After `failureThreshold` consecutive failures, kubelet kills the container and restarts it.

The pod enters `CrashLoopBackOff` if restarts keep failing. Each restart backs off with increasing wait time: 10s, 20s, 40s, 80s, up to 5 minutes.

---

## Expected state with broken probes

```
NAME                              READY   STATUS    RESTARTS   AGE
nginx-bad-probes-xxxxx-yyyyy      0/1     Running   3          5m
nginx-bad-probes-xxxxx-zzzzz      0/1     Running   3          5m
```

- READY `0/1` → readiness probe failing → pod not in Service endpoints
- RESTARTS incrementing → liveness probe failing → container being restarted

---

## Effect on Service endpoints

When a pod's readiness probe fails, it is removed from the Service's EndpointSlice. A `kubectl get endpoints` shows no addresses for that Service.

Traffic from a Service only goes to pods that pass their readiness probe. This prevents a newly starting container (still warming up) or a temporarily overloaded container from receiving requests it cannot handle.

---

## Common mistakes

**Confusing readiness and liveness**
A common mistake is putting a long-running health check in the liveness probe. If the app is temporarily slow and the liveness probe times out, Kubernetes restarts the container unnecessarily. Liveness probes should check if the process is alive, not if it is fast.

**Setting `initialDelaySeconds` too low**
If the initial delay is shorter than the app's startup time, the readiness probe fails immediately after container start and the pod oscillates between Ready and not Ready.

**Not checking probe results in Events**
When pods are not Ready, always run `kubectl describe pod` and look at Events. The probe failure events show the exact response received (status code, error message).
