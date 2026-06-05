# Lab 25 — Commands Walkthrough

## 1. Create the namespace and apply all manifests

```bash
kubectl create namespace lab-25-observe

kubectl apply -f manifests/working-app.yaml
kubectl apply -f manifests/working-svc.yaml
kubectl apply -f broken/crashloop-pod.yaml
kubectl apply -f broken/imagepull-pod.yaml
kubectl apply -f broken/configerror-pod.yaml
kubectl apply -f broken/pending-pod.yaml
kubectl apply -f broken/service-no-endpoints.yaml
```

Wait about 30 seconds then watch the pod states settle:

```bash
kubectl get pods -n lab-25-observe --watch
```

Press Ctrl-C when you have seen pods cycle through states.

> Observation questions:
> - How many distinct pod STATUS values do you see in the list?
> - Which pods are Running? Which are not?
> - Do all pods with a non-Running status show the same reason?

---

## 2. Survey all pod states at once

```bash
kubectl get pods -n lab-25-observe
```

Expected output will show pods in states such as:
- `Running`
- `CrashLoopBackOff`
- `ImagePullBackOff` or `ErrImagePull`
- `CreateContainerConfigError`
- `Pending`

> Observation questions:
> - Which pod is in CrashLoopBackOff?
> - Which pod never leaves Pending?
> - Which pod never starts its container despite the image being valid?

---

## 3. Diagnose the crash loop — describe

```bash
kubectl describe pod crashloop-demo -n lab-25-observe
```

Scroll to the **Events** section at the bottom.

> Observation questions:
> - What is the exit code shown in the Events?
> - How many times has the container restarted?
> - What is the Back-off delay shown in the events?

---

## 4. Read current logs from the crashing container

```bash
kubectl logs crashloop-demo -n lab-25-observe
```

> Observation questions:
> - What is the last line printed before the container exited?
> - Are logs available even though the container is not running right now?

---

## 5. Read logs from the previous container run

```bash
kubectl logs crashloop-demo -n lab-25-observe --previous
```

> Observation questions:
> - How does the output compare to the current logs?
> - Why is `--previous` useful when a container is actively crashing and restarting?
> - When would `--previous` return an error?

---

## 6. Diagnose the image pull failure

```bash
kubectl describe pod imagepull-demo -n lab-25-observe
```

Look at the **Events** section.

> Observation questions:
> - What exact error message appears in the Events?
> - Is the word "404" or "not found" present anywhere?
> - Would `kubectl logs imagepull-demo -n lab-25-observe` return any output? Why or why not?

---

## 7. Diagnose the config error

```bash
kubectl describe pod configerror-demo -n lab-25-observe
```

Look at the **Events** section and the **State** field under Containers.

> Observation questions:
> - What is the value of `Reason` in the container State?
> - What does the Event message say is missing?
> - Could you fix this with `kubectl edit pod`? Why or why not?

---

## 8. Diagnose the pending pod

```bash
kubectl describe pod pending-demo -n lab-25-observe
```

Look at the **Events** section.

> Observation questions:
> - What does the Event message say about why scheduling failed?
> - Does it mention specific nodes? What does it say about them?
> - What would need to change for this pod to schedule?

---

## 9. See the full cluster event timeline

```bash
kubectl get events -n lab-25-observe --sort-by=.metadata.creationTimestamp
```

> Observation questions:
> - Which failure type generates the most events?
> - Which events are typed `Warning` vs `Normal`?
> - At what point in the timeline did CrashLoopBackOff events appear relative to the initial `Pulling` events?

---

## 10. Filter events by reason

```bash
kubectl get events -n lab-25-observe --field-selector reason=Failed
```

```bash
kubectl get events -n lab-25-observe --field-selector reason=BackOff
```

```bash
kubectl get events -n lab-25-observe --field-selector reason=FailedScheduling
```

> Observation questions:
> - Which pods appear in the `Failed` reason filter?
> - What does `BackOff` tell you compared to `Failed`?
> - How could you use `--field-selector` to narrow events to a single pod?

---

## 11. Check endpoints for the broken service

```bash
kubectl get endpoints broken-svc -n lab-25-observe
```

> Observation questions:
> - What is shown in the ENDPOINTS column?
> - What does `<none>` mean for a ClusterIP service?
> - Without looking at the YAML, how would you find out which selector the service is using?

---

## 12. Check endpoints for the working service

```bash
kubectl get endpoints working-svc -n lab-25-observe
```

Compare the two outputs.

> Observation questions:
> - What IP addresses appear in the ENDPOINTS column?
> - How many endpoints are listed? Does that match the number of running pods?
> - Run `kubectl get pods -n lab-25-observe -o wide` — do the endpoint IPs match the pod IPs?

---

## 13. Exec into a running pod

First, get the name of a running working-app pod:

```bash
kubectl get pods -n lab-25-observe -l app=working-app
```

Then exec into it (replace `<pod-name>` with an actual pod name from the output above):

```bash
kubectl exec -it <pod-name> -n lab-25-observe -- nginx -v
```

> Observation questions:
> - What nginx version is reported?
> - What happens if you try to exec into imagepull-demo instead? Why?
> - What is the difference between running `kubectl exec -- nginx -v` and `kubectl exec -- sh`?

---

## 14. Fetch logs from all pods matching a label

```bash
kubectl logs -l app=working-app -n lab-25-observe
```

> Observation questions:
> - Whose logs appear — one pod or both?
> - Add `--prefix=true` to the command. What changes?
> - How is this different from targeting a single pod by name?

---

## 15. Final reflection

Answer these questions in notes.md:

1. List the five failure states you observed. For each one, which single kubectl command was most useful for diagnosing the root cause?
2. Describe in your own words the difference between `kubectl logs` and `kubectl describe` for debugging a crashing pod.
3. What does the Events section of `kubectl describe` show that `kubectl logs` cannot?
4. How can you tell the difference between ImagePullBackOff and CreateContainerConfigError from `kubectl get pods` output alone?
5. Why does broken-svc have no endpoints, and what is the minimal fix?
