# Lab 26 — Solutions and Explanations

## Scenario 1 — app-01: ImagePullBackOff

**Root cause:**
The image tag `nginx:v99.99.99-fake` does not exist on Docker Hub. Kubernetes cannot pull it.

**Diagnostic command with expected output:**
```bash
kubectl describe pod <app-01-pod-name> -n lab-26-broken
```

Events section:
```
Warning  Failed     Failed to pull image "nginx:v99.99.99-fake": rpc error: code = NotFound
                    desc = failed to pull and unpack image "docker.io/library/nginx:v99.99.99-fake":
                    failed to resolve reference "docker.io/library/nginx:v99.99.99-fake":
                    docker.io/library/nginx:v99.99.99-fake: not found
Warning  Failed     Error: ErrImagePull
Warning  BackOff    Back-off pulling image "nginx:v99.99.99-fake"
```

**ErrImagePull vs ImagePullBackOff:**
`ErrImagePull` is the immediate error on the first pull attempt. `ImagePullBackOff` is the state after Kubernetes has tried and failed multiple times and is now waiting (backing off) before retrying. They are stages of the same problem.

**The fix:**
```bash
kubectl set image deployment/app-01 nginx=nginx:stable -n lab-26-broken
# or
kubectl apply -f fixed/01-bad-image-fixed.yaml
```

**`kubectl rollout status` behaviour:**
- Before fix: hangs with "Waiting for deployment app-01 rollout to finish: 0 of 2 updated replicas are available..."
- After fix: "deployment app-01 successfully rolled out"

**Why this happens in production:**
Typos in image tags, deleted tags in a registry, or using a private registry tag without the correct `imagePullSecrets`. A CI pipeline that pushes an image but uses a different tag format than the deployment YAML is a common source.

---

## Scenario 2 — app-02: CrashLoopBackOff

**Root cause:**
`cat /etc/nonexistent/config.json` fails because the file does not exist. In a shell script, a failing command with no error handling causes the script to exit with the exit code of the failing command (1). Kubernetes treats any non-zero exit code as a container failure and restarts it.

**Diagnostic command with expected output:**
```bash
kubectl logs <app-02-pod-name> -n lab-26-broken --previous
```

Output:
```
Loading config...
cat: /etc/nonexistent/config.json: No such file or directory
```

```bash
kubectl describe pod <app-02-pod-name> -n lab-26-broken
```

Container State:
```
Last State:  Terminated
  Reason:    Error
  Exit Code: 1
  ...
```

Events:
```
Warning  BackOff  Back-off restarting failed container
```

**Why `--previous` is needed:**
By the time you check, the container may have restarted and is currently in its new (possibly still-starting) instance. The current logs may be empty or show only the beginning of the new run. `--previous` targets the terminated instance that actually produced the error.

**The fix:**
```bash
kubectl apply -f fixed/02-bad-command-fixed.yaml
```

The fixed command replaces the failing `cat` with an infinite sleep loop, keeping the container alive.

**Why this happens in production:**
Startup scripts that attempt to read config files from mounted volumes before the volume is ready, or that reference paths that differ between development and production environments.

---

## Scenario 3 — app-03: Liveness Probe Killing the Pod

**Root cause:**
The liveness probe sends HTTP GET requests to port 8080. nginx listens on port 80. The probe never succeeds, so Kubernetes kills the container after the failure threshold is reached and restarts it.

**Diagnostic command with expected output:**
```bash
kubectl describe pod <app-03-pod-name> -n lab-26-broken
```

Events:
```
Warning  Unhealthy  Liveness probe failed: Get "http://10.x.x.x:8080/healthz":
                    dial tcp 10.x.x.x:8080: connect: connection refused
Warning  Killing    Container nginx failed liveness probe, will be restarted
```

Last State:
```
Last State:  Terminated
  Reason:    Error
  Exit Code: 137
```

**Exit code 137 explained:**
Exit code 137 = 128 + 9. The 128 offset means "killed by signal". Signal 9 is SIGKILL. This means the kernel killed the process on Kubernetes' instruction — not an application crash. This is the key indicator that distinguishes probe-induced restarts from true crashes.

Exit code 1 means the application itself exited with an error. The application was in control. Exit code 137 means something external killed it.

**Why `kubectl logs` alone is misleading:**
The logs show nginx starting and serving normally. There are no error messages in the application logs. Without reading `kubectl describe` Events, the pod appears to be working fine from the logs perspective.

**The fix:**
```bash
kubectl apply -f fixed/03-bad-probe-fixed.yaml
```

Change `port: 8080` to `port: 80` in the livenessProbe spec. The fixed manifest also uses path `/` since nginx does not have a `/healthz` endpoint by default.

**Why this happens in production:**
Copying a liveness probe template from another service that runs on a different port. Changing the application port without updating the probe. Adding a health endpoint at a different path and forgetting to update the probe path.

---

## Scenario 4 — app-04: Pending (Unschedulable)

**Root cause:**
The pod requests 64 CPUs and 256Gi memory. A standard kind node has 2–4 CPU cores and 4–8Gi of memory depending on the host. No node can satisfy the request.

**Diagnostic command with expected output:**
```bash
kubectl describe pod <app-04-pod-name> -n lab-26-broken
```

Events:
```
Warning  FailedScheduling  0/3 nodes are available:
  3 Insufficient cpu, 3 Insufficient memory.
  preemption: 0/3 nodes are available: 3 No preemption victims found for incoming pod...
```

```bash
kubectl describe nodes | grep -A 5 "Allocated resources"
```

This shows how much CPU and memory is currently allocated on each node, helping you see whether the request is simply too large or whether the cluster is just over-provisioned.

**Other causes of Pending:**
1. Taint on all nodes with no matching toleration on the pod
2. nodeSelector or affinity that no node matches
3. PVC referenced by the pod is still Pending (unbound volume)
4. Namespace resource quota exceeded
5. Pod security admission or policy rejection

**`kubectl rollout status` for a Pending deployment:**
It will block indefinitely:
```
Waiting for deployment app-04 rollout to finish: 0 of 1 updated replicas are available...
```
It does not tell you *why* — you must look at the pod with `kubectl describe`.

**The fix:**
```bash
kubectl apply -f fixed/04-pending-resources-fixed.yaml
```

Or patch directly:
```bash
kubectl patch deployment app-04 -n lab-26-broken \
  --patch '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"requests":{"cpu":"100m","memory":"128Mi"}}}]}}}}'
```

**Why this happens in production:**
Copy-paste of resource requests from a production cluster (which has large nodes) into a staging cluster (which has small nodes). Accidentally specifying CPU in full cores (`64`) instead of millicores (`64m`). Setting memory to Gi instead of Mi.

---

## Recommended Triage Order

For any unknown broken deployment:

1. `kubectl get pods -n <ns>` — identify the STATUS column and which pods are affected
2. `kubectl rollout status deployment/<name> -n <ns>` — confirm the rollout is stuck
3. `kubectl describe pod <pod-name> -n <ns>` — read Events: this tells you why 80% of the time
4. `kubectl logs <pod-name> -n <ns> --previous` — read application output for crashes
5. `kubectl get events -n <ns> --sort-by=.metadata.creationTimestamp` — timeline of all events

**When to use `kubectl edit` vs apply a fixed YAML:**
- `kubectl edit` is fast for one-liner fixes in an exam or emergency
- Applying a fixed YAML is auditable, version-controlled, and repeatable — use it in production
- For fields that are immutable (like `selector.matchLabels`), you must delete and recreate regardless of method
