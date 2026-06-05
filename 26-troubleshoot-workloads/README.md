# Lab 26 — Troubleshoot Workloads

## Goal
Diagnose and fix four broken deployments, each demonstrating a distinct failure mode that appears regularly in production and on the CKA exam.

## Teaches
- Recognising ImagePullBackOff, CrashLoopBackOff, liveness probe failures, and Pending in Deployment rollouts
- Using `kubectl rollout status`, `kubectl describe`, `kubectl logs`, and `kubectl get events` to locate root causes
- Applying fixes with `kubectl apply`, `kubectl set image`, and `kubectl edit`
- Verifying a rollout completed successfully

## Prerequisites
- Lab 25 or equivalent familiarity with `kubectl logs`, `describe`, and pod states
- Kind cluster running with nodes: kind-control-plane, kind-worker, kind-worker2

## What You Will Build
A namespace with four failing deployments. You will diagnose each one, apply the corresponding fixed manifest, and verify the rollout.

## Files

```
broken/
  01-bad-image.yaml             nginx:v99.99.99-fake — ImagePullBackOff
  02-bad-command.yaml           busybox cat nonexistent file — CrashLoopBackOff
  03-bad-probe.yaml             nginx with liveness probe on wrong port — probe kills pod
  04-pending-resources.yaml     nginx requesting 64 CPUs and 256Gi — Pending
fixed/
  01-bad-image-fixed.yaml       corrected image tag
  02-bad-command-fixed.yaml     corrected command
  03-bad-probe-fixed.yaml       corrected liveness probe port
  04-pending-resources-fixed.yaml  corrected resource requests
commands.md                     Scenario-based walkthrough
notes.md                        Blank workbook
solutions.md                    Full answers and explanations
cleanup.sh                      Tears down lab namespace
```

## Success Criteria
- You can identify all four failure modes from `kubectl get pods` and `kubectl describe` output alone
- You understand why the liveness probe failure causes repeated restarts even though the image is fine
- You can apply a fix and confirm the deployment rolls out successfully with `kubectl rollout status`

## Difficulty
Intermediate (CKA Domain: Troubleshooting)
