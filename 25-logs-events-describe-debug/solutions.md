# Lab 25 — Solutions and Explanations

## Quick-Reference Triage Table

| State | First command | What to look for |
|-------|--------------|-----------------|
| CrashLoopBackOff | `kubectl logs --previous` | Exit code, last error line printed before exit |
| ImagePullBackOff | `kubectl describe pod` | Events: "Failed to pull image", 404/not found/unauthorized |
| CreateContainerConfigError | `kubectl describe pod` | Events: "configmap not found" or "secret not found" |
| Pending | `kubectl describe pod` | Events: "Insufficient cpu", "Insufficient memory", "no nodes available" |
| Service no endpoints | `kubectl get endpoints` | Empty ADDRESSES column — selector mismatch |

---

## Failure Mode 1 — CrashLoopBackOff (crashloop-demo)

**What it is:**
The container starts, runs, exits with a non-zero exit code, and Kubernetes restarts it. After repeated failures the restart delay grows exponentially (10s, 20s, 40s, 80s…) — this is the "back-off" in CrashLoopBackOff.

**Root cause in this lab:**
The command explicitly calls `exit 1` after printing a fatal message.

**Diagnostic commands:**

```bash
# See restart count and last state exit code
kubectl describe pod crashloop-demo -n lab-25-observe

# See output from the currently running (or most recent) container instance
kubectl logs crashloop-demo -n lab-25-observe

# See output from the PREVIOUS container run — critical when the container restarts before you look
kubectl logs crashloop-demo -n lab-25-observe --previous
```

In `kubectl describe` output, look for:
```
Last State:  Terminated
  Reason:    Error
  Exit Code: 1
```
And in Events:
```
Warning  BackOff  Back-off restarting failed container
```

**Why `--previous` matters:**
If a container restarts between the time you notice the problem and the time you run `kubectl logs`, the current log buffer is from the new (possibly still-starting) instance. `--previous` gives you the log from the container run that actually failed. Without it you may see an empty log or an incomplete one.

**Common mistakes:**
- Running `kubectl logs` without `--previous` and seeing "Starting up..." then assuming the container is healthy — it just started again.
- Trying to fix CrashLoopBackOff by deleting and recreating the pod without changing the underlying command or config.

---

## Failure Mode 2 — ImagePullBackOff (imagepull-demo)

**What it is:**
Kubernetes cannot pull the container image from the registry. Like CrashLoopBackOff, it retries with exponential back-off.

**Root cause in this lab:**
The tag `nginx:version-does-not-exist-99` does not exist in Docker Hub.

**Diagnostic commands:**

```bash
kubectl describe pod imagepull-demo -n lab-25-observe
```

In Events you will see:
```
Warning  Failed   Failed to pull image "nginx:version-does-not-exist-99": ... 404 Not Found
Warning  Failed   Error: ErrImagePull
Warning  BackOff  Back-off pulling image "nginx:version-does-not-exist-99"
```

**Why `kubectl logs` returns nothing:**
The container never started. There is no process to produce logs. `kubectl logs` will return an error like "container is in waiting state".

**Common mistakes:**
- Confusing ImagePullBackOff (bad tag or registry) with ErrImageNeverPull (imagePullPolicy: Never but image not cached locally).
- Forgetting that private registries require an `imagePullSecrets` entry.
- Typing a tag that looks valid (like `nginx:latest`) but pointing to a private registry without credentials.

---

## Failure Mode 3 — CreateContainerConfigError (configerror-demo)

**What it is:**
The container image was pulled successfully but Kubernetes cannot configure the container because a referenced ConfigMap or Secret does not exist. The container never starts.

**Root cause in this lab:**
The pod references `configMapKeyRef: name: missing-config` but that ConfigMap was never created.

**Diagnostic commands:**

```bash
kubectl describe pod configerror-demo -n lab-25-observe
```

In the Containers section:
```
State:  Waiting
  Reason: CreateContainerConfigError
```

In Events:
```
Warning  Failed  Error: configmap "missing-config" not found
```

**Why `kubectl logs` returns nothing:**
Same reason as ImagePullBackOff — the container process was never launched. There are no logs to read.

**The fix:**
Either create the missing ConfigMap or remove the env reference:
```bash
kubectl create configmap missing-config --from-literal=color=blue -n lab-25-observe
```
The pod will recover automatically once the ConfigMap exists.

**Common mistakes:**
- Trying `kubectl edit pod` to remove the env reference — pods are largely immutable once created; you must delete and recreate.
- Assuming the image is bad when actually the config reference is broken.

---

## Failure Mode 4 — Pending (pending-demo)

**What it is:**
The Kubernetes scheduler cannot find any node that satisfies the pod's requirements. The pod sits in Pending indefinitely.

**Root cause in this lab:**
The pod requests 500 CPUs and 999Gi of memory — vastly more than any kind node provides.

**Diagnostic commands:**

```bash
kubectl describe pod pending-demo -n lab-25-observe
```

In Events:
```
Warning  FailedScheduling  0/3 nodes are available:
  3 Insufficient cpu, 3 Insufficient memory.
  preemption: 0/3 nodes are available: 3 No preemption victims found...
```

**Other Pending causes:**
- Taint on all nodes with no matching toleration on the pod
- nodeSelector or affinity that no node satisfies
- PVC not bound (pod awaits a volume)
- Namespace resource quota exceeded

**Common mistakes:**
- Thinking the pod is "just slow to start" — Pending means scheduling has not happened at all.
- Forgetting that resource `requests` are what the scheduler uses, not `limits`.

---

## Failure Mode 5 — Service No Endpoints (broken-svc)

**What it is:**
A Service exists and is reachable in DNS, but no pods match its label selector so no traffic can be forwarded anywhere. Connections will time out or be refused depending on the client.

**Root cause in this lab:**
The Service selector is `app: working-appp` (three p's) instead of `app: working-app`.

**Diagnostic commands:**

```bash
# Shows empty ENDPOINTS column
kubectl get endpoints broken-svc -n lab-25-observe

# Shows the selector the service is using
kubectl describe svc broken-svc -n lab-25-observe | grep Selector

# Shows the labels on running pods
kubectl get pods -n lab-25-observe --show-labels
```

Compare the Selector value to the pod labels — the mismatch is immediately visible.

**The fix (no delete required):**

```bash
kubectl patch svc broken-svc -n lab-25-observe \
  -p '{"spec":{"selector":{"app":"working-app"}}}'
```

Verify:
```bash
kubectl get endpoints broken-svc -n lab-25-observe
```

**Common mistakes:**
- Assuming the service is broken when in fact only the selector is wrong.
- Deleting and recreating the service instead of patching the selector.
- Checking the Service port and targetPort before checking whether any endpoints exist.

---

## Reference: kubectl Observability Commands

| Command | Purpose |
|---------|---------|
| `kubectl get pods -n <ns>` | Overview of all pod states |
| `kubectl get pods -n <ns> -o wide` | Adds node assignment and pod IP |
| `kubectl describe pod <name> -n <ns>` | Full spec, conditions, and events for one pod |
| `kubectl logs <pod> -n <ns>` | Current container stdout/stderr |
| `kubectl logs <pod> -n <ns> --previous` | Previous container instance logs |
| `kubectl logs -l <label> -n <ns>` | Logs from all pods matching a label |
| `kubectl logs -l <label> -n <ns> --prefix=true` | Same but prefixes each line with pod name |
| `kubectl get events -n <ns> --sort-by=.metadata.creationTimestamp` | All events in chronological order |
| `kubectl get events -n <ns> --field-selector reason=Failed` | Filter events by reason |
| `kubectl get endpoints <svc> -n <ns>` | See which pod IPs a service forwards to |
| `kubectl exec -it <pod> -n <ns> -- <cmd>` | Run a command inside a running container |
