# Lab 25 — Logs, Events, Describe, Debug

## Goal
Master the core Kubernetes observability toolkit to diagnose five distinct failure states without guessing.

## Teaches
- Reading pod Events in `kubectl describe` output
- Using `kubectl logs` and `kubectl logs --previous`
- Filtering events with `kubectl get events --field-selector`
- Diagnosing CrashLoopBackOff, ImagePullBackOff, CreateContainerConfigError, Pending, and service endpoint failures
- Exec into running pods with `kubectl exec`
- Correlating service selectors to pod labels via `kubectl get endpoints`

## Prerequisites
- Comfortable with `kubectl get`, `kubectl apply`, and basic pod concepts
- Kind cluster running with nodes: kind-control-plane, kind-worker, kind-worker2

## What You Will Build
A namespace with one healthy nginx deployment and five intentionally broken resources covering the most common failure modes seen in production and on the CKA exam.

## Files

```
manifests/
  working-app.yaml        nginx:stable Deployment, 2 replicas, label app=working-app
  working-svc.yaml        ClusterIP Service with correct selector
broken/
  crashloop-pod.yaml      busybox pod that exits 1 — CrashLoopBackOff
  imagepull-pod.yaml      pod with a non-existent image tag — ImagePullBackOff
  configerror-pod.yaml    pod referencing a missing ConfigMap — CreateContainerConfigError
  pending-pod.yaml        pod requesting 500 CPUs and 999Gi — Pending forever
  service-no-endpoints.yaml  Service with a typo in its selector — no endpoints
commands.md               Step-by-step diagnostic walkthrough
notes.md                  Blank workbook — answer the questions yourself
solutions.md              Full answers, explanations, triage table
cleanup.sh                Tears down the lab namespace
```

## Success Criteria
- You can name the kubectl command that best diagnoses each of the five failure states
- You understand what `kubectl logs --previous` reveals that `kubectl logs` does not
- You can explain why broken-svc has no endpoints and how to fix it without deleting the service
- You can exec into a running pod and run a command inside it

## Difficulty
Beginner–Intermediate (CKA Domain: Troubleshooting)
