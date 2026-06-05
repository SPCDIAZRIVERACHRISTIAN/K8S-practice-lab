# Solutions — 06 Services: ClusterIP and NodePort

---

## Why pod IPs are unstable

Every time a pod is created, it gets a new IP address assigned by the CNI plugin. When a pod is deleted and recreated (by a Deployment during a rollout, a crash, or a scale event), the new pod gets a different IP.

Any client that hardcoded the old pod IP will break. Services solve this by providing a stable virtual IP (the ClusterIP) that never changes, and routing traffic to healthy pods behind it.

---

## ClusterIP

```
Client (inside cluster)
  ↓
ClusterIP (stable virtual IP, managed by kube-proxy)
  ↓
One of the matching pods (selected by label)
```

- ClusterIP is only reachable from within the cluster
- kube-proxy on each node maintains iptables rules that DNAT the ClusterIP to a real pod IP
- If a pod is deleted and replaced, kube-proxy updates the rules automatically

---

## NodePort

```
Client (outside cluster)
  ↓
NodeIP:NodePort (e.g., 172.18.0.2:30080)
  ↓
ClusterIP:Port
  ↓
Pod
```

- A NodePort opens the same port on every node in the cluster
- Traffic hitting any node on that port is forwarded to the ClusterIP
- NodePort range: 30000–32767 by default
- In kind, node IPs are on an internal Docker bridge network. Direct access from your host may not work without extra port-mapping in kind-config.yaml.

---

## Expected output: kubectl get endpoints

```
NAME              ENDPOINTS                                      AGE
nginx-clusterip   10.244.1.4:80,10.244.2.3:80,10.244.2.4:80   2m
nginx-broken      <none>                                         30s
```

The broken service shows `<none>` because its selector `app: nginnx` matches zero pods.

---

## How to diagnose a selector mismatch

1. `kubectl describe service <name> -n <ns>` — shows the selector the service is using
2. `kubectl get pods -n <ns> --show-labels` — shows the actual labels on pods
3. Compare selector to labels — if they do not match exactly, the service has no endpoints

This is one of the most common Kubernetes troubleshooting scenarios. The symptom is always the same: the service has an IP but no endpoints, and traffic drops silently.

---

## What happens to endpoints when a pod is replaced

When a Deployment replaces a pod (due to deletion, rollout, or crash):
1. Old pod is terminated → kube-proxy removes it from the endpoints
2. New pod starts → readiness probe passes → kube-proxy adds new pod IP to endpoints

The ClusterIP itself never changes. Clients connected through the Service reconnect transparently to the new pod on the next request.

---

## Common mistakes

**Confusing `port` and `targetPort` in a Service**
- `port` is what clients connect to on the Service IP
- `targetPort` is what the traffic is forwarded to on the pod

If your container listens on port 8080 but you set `targetPort: 80`, traffic will be forwarded to port 80 on the pod and fail.

**Expecting NodePort to work directly from your Mac/Windows host**
kind runs nodes as Docker containers on a bridge network. That network is not directly routable from your host. Use `kubectl port-forward` for local testing, or configure kind with `extraPortMappings` to expose ports on localhost.
