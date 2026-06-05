# Lab 19 — Security Contexts & Pod Security Admission

## Goal

Understand how to lock down pod and container execution at the OS level using `securityContext`, and how Kubernetes enforces security policies at namespace level using Pod Security Admission (PSA).

## Teaches

- `securityContext` at pod level vs container level
- `runAsNonRoot`, `runAsUser`, `runAsGroup`, `fsGroup`
- `readOnlyRootFilesystem` — blocking writes to container filesystem
- `allowPrivilegeEscalation` — blocking setuid/sudo escalation
- `capabilities.drop: ["ALL"]` — removing Linux capabilities
- `seccompProfile` — syscall filtering profiles
- Pod Security Admission (PSA) — built into Kubernetes 1.25+
- Three PSA levels: `privileged`, `baseline`, `restricted`
- Three PSA modes: `enforce`, `warn`, `audit`
- How PSA labels on a namespace gate pod creation at admission time

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`)
- Familiar with pod specs (Lab 01)

## What You Will Build

Two namespaces with different security postures:
- `lab-19-security` — labeled with `restricted` PSA enforcement
- `lab-19-baseline` — labeled with `baseline` PSA enforcement

You will:
1. Deploy a fully compliant pod with all security context fields set
2. Attempt to deploy broken pods (running as root, privileged, missing capability drops)
3. Watch the admission controller reject them with clear error messages
4. Understand which PSA violation caused each rejection

## Files

```
manifests/
  namespace-restricted.yaml   — lab-19-security: enforce=restricted, warn=restricted, audit=restricted
  namespace-baseline.yaml     — lab-19-baseline: enforce=baseline
  pod-secure.yaml             — fully compliant pod for restricted namespace
  pod-minimal-context.yaml    — baseline-compliant pod (runs as non-root not enforced)

broken/
  pod-root.yaml               — no securityContext, runs as root — rejected in restricted
  pod-privileged.yaml         — privileged: true, runAsUser: 0 — rejected in baseline and restricted
  pod-missing-caps-drop.yaml  — missing capabilities.drop: ALL — rejected in restricted
```

## Success Criteria

- `pod-secure.yaml` deploys and reaches `Running` in `lab-19-security`
- `pod-root.yaml` is rejected by the admission controller with a PSA violation message
- `pod-privileged.yaml` is rejected even in `lab-19-baseline`
- `pod-missing-caps-drop.yaml` is rejected in `lab-19-security` but would pass in `lab-19-baseline`
- You can explain which PSA level blocks which violation
- You can read the rejection error and identify the specific field that needs to be fixed

## Difficulty

Medium — the security context fields are straightforward, but understanding why the restricted level requires `seccompProfile` and capability drops surprises most people.
