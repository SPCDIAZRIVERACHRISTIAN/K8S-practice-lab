# Lab 26 — Commands Walkthrough

## Setup

```bash
kubectl create namespace lab-26-broken

kubectl apply -f broken/01-bad-image.yaml
kubectl apply -f broken/02-bad-command.yaml
kubectl apply -f broken/03-bad-probe.yaml
kubectl apply -f broken/04-pending-resources.yaml
```

Wait about 30 seconds then check the overall state:

```bash
kubectl get pods -n lab-26-broken
```

> Observation question: Before looking at individual deployments, can you match each pod STATUS to one of the four deployments based on the name prefix alone?

---

## Scenario 1 — app-01: ImagePullBackOff

### Symptom

```bash
kubectl get pods -n lab-26-broken -l app=app-01
```

The pods show `ErrImagePull` or `ImagePullBackOff` in the STATUS column.

### Diagnose

```bash
kubectl describe pod -n lab-26-broken -l app=app-01
```

Or pick a specific pod name and run:

```bash
kubectl describe pod <app-01-pod-name> -n lab-26-broken
```

Look at the Events section. You will see:
```
Failed to pull image "nginx:v99.99.99-fake": ... 404 Not Found
```

```bash
# Also check rollout status — it will be stuck
kubectl rollout status deployment/app-01 -n lab-26-broken
```

> Observation questions:
> - Which field in the Events output tells you the tag does not exist?
> - Would `kubectl logs` help here? Why or why not?

### Fix

Apply the fixed manifest:

```bash
kubectl apply -f fixed/01-bad-image-fixed.yaml
```

Alternatively, patch the image directly:

```bash
kubectl set image deployment/app-01 nginx=nginx:stable -n lab-26-broken
```

### Verify

```bash
kubectl rollout status deployment/app-01 -n lab-26-broken
kubectl get pods -n lab-26-broken -l app=app-01
```

> Observation question: How does `kubectl rollout status` behave differently before and after the fix?

---

## Scenario 2 — app-02: CrashLoopBackOff

### Symptom

```bash
kubectl get pods -n lab-26-broken -l app=app-02
```

Pods show `CrashLoopBackOff`. The RESTARTS column climbs over time.

### Diagnose

```bash
kubectl logs -n lab-26-broken -l app=app-02
```

```bash
kubectl logs -n lab-26-broken <app-02-pod-name> --previous
```

Look for the error message and exit code.

```bash
kubectl describe pod -n lab-26-broken -l app=app-02
```

In Events:
```
Warning  BackOff  Back-off restarting failed container
```

In the container State section, find the exit code.

> Observation questions:
> - What was the last line printed before the container exited?
> - What exit code was returned?
> - Why does the shell command `cat /etc/nonexistent/config.json` cause an exit code 1?

### Fix

```bash
kubectl apply -f fixed/02-bad-command-fixed.yaml
```

Or use `kubectl edit deployment/app-02 -n lab-26-broken` to change the command inline.

### Verify

```bash
kubectl rollout status deployment/app-02 -n lab-26-broken
kubectl get pods -n lab-26-broken -l app=app-02
```

The RESTARTS column should stop increasing once the fix rolls out.

---

## Scenario 3 — app-03: Liveness Probe Killing the Pod

### Symptom

```bash
kubectl get pods -n lab-26-broken -l app=app-03
```

Pods may initially show `Running` but the RESTARTS counter increases steadily. Eventually the STATUS may flip to `CrashLoopBackOff`.

This looks identical to a crashing application — the key is reading the restart reason.

### Diagnose

```bash
kubectl describe pod <app-03-pod-name> -n lab-26-broken
```

In Events you will see:
```
Warning  Unhealthy  Liveness probe failed: Get "http://...:8080/healthz": dial tcp ...:8080: connect: connection refused
Warning  Killing    Container nginx failed liveness probe, will be restarted
```

In the container State:
```
Last State:  Terminated
  Reason:    Error
  Exit Code: 137
```

Exit code 137 means the process was killed by signal 9 (SIGKILL), not by the application itself.

> Observation questions:
> - What port is the liveness probe checking?
> - What port does nginx actually listen on?
> - Why is exit code 137 a signal that the container was killed externally rather than crashing?
> - Could you diagnose this from `kubectl logs` alone? What would the logs show?

### Fix

```bash
kubectl apply -f fixed/03-bad-probe-fixed.yaml
```

Or edit the deployment directly:

```bash
kubectl edit deployment/app-03 -n lab-26-broken
```

Change `port: 8080` to `port: 80` under `livenessProbe.httpGet`.

### Verify

```bash
kubectl rollout status deployment/app-03 -n lab-26-broken
kubectl get pods -n lab-26-broken -l app=app-03
```

Watch the RESTARTS column — it should stop increasing.

---

## Scenario 4 — app-04: Pending (Unschedulable)

### Symptom

```bash
kubectl get pods -n lab-26-broken -l app=app-04
```

Pod shows `Pending`. It never transitions to `ContainerCreating` or `Running`.

### Diagnose

```bash
kubectl describe pod <app-04-pod-name> -n lab-26-broken
```

In Events:
```
Warning  FailedScheduling  0/3 nodes are available:
  3 Insufficient cpu, 3 Insufficient memory.
```

```bash
# Check what each node actually has available
kubectl describe nodes | grep -A 5 "Allocated resources"
```

> Observation questions:
> - What did the pod request vs what any node can provide?
> - Would adding more replicas help? Why or why not?
> - Is the pod stuck in Pending because of a node problem or a pod problem?

### Fix

```bash
kubectl apply -f fixed/04-pending-resources-fixed.yaml
```

Or patch the resource requests:

```bash
kubectl patch deployment app-04 -n lab-26-broken \
  --patch '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"requests":{"cpu":"100m","memory":"128Mi"}}}]}}}}'
```

### Verify

```bash
kubectl rollout status deployment/app-04 -n lab-26-broken
kubectl get pods -n lab-26-broken -l app=app-04
```

---

## Final Check — All Deployments Healthy

```bash
kubectl get deployments -n lab-26-broken
kubectl get pods -n lab-26-broken
```

All deployments should show `READY` with all replicas available.

```bash
kubectl rollout status deployment/app-01 -n lab-26-broken
kubectl rollout status deployment/app-02 -n lab-26-broken
kubectl rollout status deployment/app-03 -n lab-26-broken
kubectl rollout status deployment/app-04 -n lab-26-broken
```

> Final observation question: In a real incident, what is the order in which you would run these commands to triage an unknown broken deployment as quickly as possible?
