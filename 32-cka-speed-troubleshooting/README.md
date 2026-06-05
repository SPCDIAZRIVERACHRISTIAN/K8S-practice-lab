# Lab 32 — cka-speed-troubleshooting

## Goal

Timed troubleshooting scenarios. Apply the setup manifests, then diagnose and fix each broken scenario within the target time. **Do not look at the setup manifests before starting** — treat each symptom as you would in a real exam.

**Target:** Diagnose and fix all 5 scenarios in under 35 minutes total.

---

## Teaches

- Diagnosing ImagePullBackOff
- Identifying service selector mismatches (no endpoints)
- Diagnosing CreateContainerConfigError from wrong ConfigMap keys
- Diagnosing Pending pods due to impossible resource requests
- Diagnosing and fixing a failing liveness probe

---

## Prerequisites

- Running kind cluster with nodes: `kind-control-plane`, `kind-worker`, `kind-worker2`
- `kubectl` configured and pointing at the cluster

---

## Setup

**Apply all setup manifests before starting the timed tasks. Do not read them first.**

```bash
kubectl apply -f setup/namespace.yaml
kubectl apply -f setup/01-broken-deployment.yaml
kubectl apply -f setup/02-broken-service.yaml
kubectl apply -f setup/03-broken-configmap-pod.yaml
kubectl apply -f setup/04-pending-pod.yaml
kubectl apply -f setup/05-bad-probe.yaml
```

Wait 30 seconds, then begin Task 1.

---

## What You Will Do

Work through 5 broken scenarios in namespace `speed-32`. Each has a single root cause. Find it and fix it.

---

## Files

| File | Purpose |
|------|---------|
| `setup/` | Broken manifests — apply before starting, do not read first |
| `tasks.md` | Symptom descriptions and fix targets — no hints |
| `hints.md` | Brief hints for each scenario if you get stuck |
| `solutions.md` | Full diagnosis steps, root cause, fix command, and verification |
| `notes.md` | Workbook — fill in after completing tasks |
| `cleanup.sh` | Tear down all resources created in this lab |

---

## Success Criteria

- All 5 deployments/pods running correctly after your fixes
- Total time under 35 minutes
- You can articulate the root cause of each scenario

---

## Difficulty

**Hard** — No hints in the task file. Diagnose from symptoms alone.
