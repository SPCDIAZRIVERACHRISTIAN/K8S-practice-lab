# Lab 27 — Troubleshoot Networking

## Goal
Diagnose three distinct service networking failures and understand the relationship between services, selectors, endpoints, ports, and DNS.

## Teaches
- How Kubernetes services route traffic via endpoint slices
- Using `kubectl get endpoints` to detect selector mismatches
- Distinguishing between an empty endpoints list (selector problem) and connection refused (targetPort problem)
- Kubernetes DNS resolution — short names, service.namespace, and FQDN
- Fixing services with `kubectl patch` and `kubectl edit`

## Prerequisites
- Comfortable with pods, services, labels, and `kubectl exec`
- Kind cluster running with nodes: kind-control-plane, kind-worker, kind-worker2

## What You Will Build
A namespace with a healthy backend deployment and a client pod, plus three broken networking scenarios: a service with a selector typo, a service with a wrong targetPort, and a pod using the wrong DNS name.

## Files

```
manifests/
  namespace.yaml              lab-27-network namespace
  backend-deployment.yaml     nginx:stable, 2 replicas, label app=backend
  client-pod.yaml             busybox sleep pod for testing connectivity
broken/
  service-wrong-selector.yaml   backend-svc with selector typo (backennnd)
  service-wrong-port.yaml       backend-port-svc with targetPort 9090 (nginx is on 80)
  service-wrong-name-pod.yaml   pod that tries to reach http://backend (wrong service name)
commands.md                   Step-by-step diagnostic walkthrough
notes.md                      Blank workbook
solutions.md                  Full answers, fix commands, DNS explanation
cleanup.sh                    Tears down the lab namespace
```

## Success Criteria
- You can explain why an endpoint list is empty even when pods are running
- You can distinguish a selector problem from a targetPort problem using only kubectl
- You understand the three DNS name forms available inside a pod
- You can fix a service selector without deleting the service

## Difficulty
Intermediate (CKA Domain: Services and Networking / Troubleshooting)
