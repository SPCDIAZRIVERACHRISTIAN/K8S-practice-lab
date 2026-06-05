# Solutions — 14 Autoscaling: HPA Basics

---

## How the HPA calculates desired replicas

The HPA uses this formula:

```
desiredReplicas = ceil(currentReplicas × (currentUtilization / targetUtilization))
```

With `targetUtilization: 50` (50%), `cpu request: 200m`, and 1 pod using 300m CPU:

```
utilization = 300m / 200m = 150%
desiredReplicas = ceil(1 × (150 / 50)) = ceil(3) = 3
```

The HPA scales up to 3 replicas to bring per-pod utilization down toward 50%.

CPU utilization % is always relative to the pod's CPU **request**, not the CPU limit or the node total. This is why requests are mandatory.

---

## Why requests are required

Without a CPU request, there is no baseline to calculate utilization against. The HPA cannot compute a percentage when the denominator is undefined.

When you remove CPU requests, the HPA condition shows:
```
AbleToScale: False
ScalingActive: False
reason: FailedGetResourceMetric
message: failed to get cpu utilization: missing request for cpu
```

The TARGETS column shows `<unknown>/50%`.

---

## metrics-server in kind

metrics-server scrapes metrics from kubelet's HTTPS endpoint on each node. In a production cluster, kubelets have valid certificates. In kind, kubelets use self-signed certificates that metrics-server cannot verify by default.

The `--kubelet-insecure-tls` flag tells metrics-server to skip TLS certificate verification for kubelet connections. This is safe in a local kind environment but should never be used in production.

---

## Scale-up vs scale-down timing

| Direction | Default behavior |
|-----------|-----------------|
| Scale up | Relatively fast — acts within 15–30 seconds of sustained high utilization |
| Scale down | Conservative — waits 5 minutes by default (controlled by `--horizontal-pod-autoscaler-downscale-stabilization`) |

The scale-down delay exists to prevent flapping: under variable load, pods would constantly scale up and down without a stabilization window. The 5-minute window ensures that utilization is consistently low before removing replicas.

---

## HPA conditions to know

In `kubectl describe hpa`:

| Condition | Meaning |
|-----------|---------|
| `AbleToScale: True` | The HPA can make scaling decisions |
| `ScalingActive: True` | The HPA has active metrics and is monitoring |
| `ScalingLimited: True` | The HPA wants to scale but is at min or max replicas |

---

## registry.k8s.io/hpa-example

This is the official Kubernetes HPA demo image. It runs a PHP script that performs CPU-intensive computation on every request, making it easy to generate measurable CPU load with a simple wget loop.

---

## Common mistakes

**Expecting HPA to work immediately after applying**
metrics-server needs time to collect initial metrics. The HPA TARGETS column shows `<unknown>` until the first metric scrape completes (usually 30–60 seconds).

**Not setting CPU requests on the Deployment**
HPA will not function without CPU requests. This is the single most common HPA setup mistake.

**Setting targetUtilization too low**
A target of 10% CPU means the HPA will scale up heavily even under light load. 50–70% is a reasonable starting point for most workloads.

**Assuming HPA replaces manual scaling**
HPA reacts to load. It does not predict or pre-warm. For applications with known traffic spikes (e.g., scheduled batch jobs), pre-scaling manually or using KEDA (event-driven autoscaling) is more appropriate.
