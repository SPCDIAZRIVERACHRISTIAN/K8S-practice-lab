# Lab 27 — Solutions and Explanations

## How Kubernetes Service Traffic Works

```
Client Pod
    |
    v
Service ClusterIP (kube-proxy / iptables rule)
    |
    v
Endpoint IPs (pod IPs selected by service selector)
    |
    v
Container port (targetPort on each pod)
```

When any link in this chain is broken, the traffic fails in a specific way. The key diagnostic skill is knowing which symptom points to which broken link.

---

## Problem 1 — Service Wrong Selector (backend-svc)

**Symptom:**
Connection times out. The client waits and gets no response.

**Root cause:**
The service selector `app: backennnd` (three n's) matches no pods. The endpoint list is empty. kube-proxy has no pod IPs to forward traffic to, so packets are dropped.

**Diagnostic commands:**

```bash
# Step 1: confirm no endpoints exist
kubectl get endpoints backend-svc -n lab-27-network
# Output: NAME          ENDPOINTS   AGE
#         backend-svc   <none>      ...

# Step 2: see what selector the service is using
kubectl describe svc backend-svc -n lab-27-network | grep -i selector
# Output: Selector: app=backennnd

# Step 3: see what labels the pods actually have
kubectl get pods -n lab-27-network --show-labels
# Output: ... app=backend ...

# The mismatch is visible immediately
```

**Fix:**
```bash
kubectl patch svc backend-svc -n lab-27-network \
  -p '{"spec":{"selector":{"app":"backend"}}}'
```

After the patch, Kubernetes immediately recalculates the endpoint slice. No restart required.

**Verify:**
```bash
kubectl get endpoints backend-svc -n lab-27-network
# Should show 2 IP addresses
```

**Why this happens in production:**
Copy-paste errors in selectors, renaming a deployment label without updating all services, case-sensitivity mistakes (`App` vs `app`).

---

## Problem 2 — Service Wrong targetPort (backend-port-svc)

**Symptom:**
Connection refused immediately. The client receives an RST packet from the pod's kernel because nothing is listening on port 9090.

This is different from the selector problem (timeout) — refused means the connection reached a pod but was rejected at the OS level.

**Root cause:**
The selector is correct so endpoints are populated, but `targetPort: 9090` tells kube-proxy to forward to port 9090 on each pod. nginx listens on 80. Port 9090 has no listener so the kernel sends a TCP RST.

**Diagnostic commands:**

```bash
# Step 1: endpoints are populated — selector is fine
kubectl get endpoints backend-port-svc -n lab-27-network
# Output: NAME               ENDPOINTS                     AGE
#         backend-port-svc   10.x.x.x:9090,10.x.x.x:9090  ...

# Step 2: examine the service spec
kubectl describe svc backend-port-svc -n lab-27-network
# Port section shows:
#   Port:       <unset>  80/TCP
#   TargetPort: 9090/TCP

# Step 3: confirm what port nginx actually uses
kubectl exec -it client -n lab-27-network -- wget -qO- http://backend-svc:80
# This succeeds — proving port 80 works
```

**The key insight:** Endpoints being populated tells you the selector is correct but says nothing about whether the application is listening on that port.

**Fix:**
```bash
kubectl patch svc backend-port-svc -n lab-27-network \
  -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
```

**Why this happens in production:**
The application was changed to run on a different port and the service was not updated. A template with a hardcoded targetPort was reused for a different application. Named ports can help avoid this — using `targetPort: http` instead of `targetPort: 80` when the container defines a named port.

---

## Problem 3 — DNS Name Wrong (wrong-dns-client)

**Symptom:**
Pod logs show wget errors like:
```
wget: bad address 'backend'
```
or
```
nslookup: can't resolve 'backend'
```

**Root cause:**
The pod requests `http://backend`. Kubernetes DNS expands short names within the same namespace: `backend` resolves to `backend.lab-27-network.svc.cluster.local`. There is no service named `backend` — the service is named `backend-svc`. The DNS query returns NXDOMAIN.

**Diagnostic commands:**

```bash
# Confirm what DNS returns for the wrong name
kubectl exec -it client -n lab-27-network -- nslookup backend
# Output: can't resolve 'backend'

# Confirm the correct name works
kubectl exec -it client -n lab-27-network -- nslookup backend-svc
# Output: resolves to the service ClusterIP

# Check the pod logs to see the error pattern
kubectl logs wrong-dns-client -n lab-27-network
```

**Fix:**
The wrong-dns-client pod has a hardcoded URL in its command. Pods are immutable once created — you must delete and recreate with the corrected URL pointing to `backend-svc`.

---

## Kubernetes DNS Resolution — The Three Forms

From inside a pod in namespace `lab-27-network`:

| Name form | Example | Works from | Notes |
|-----------|---------|-----------|-------|
| Short name | `backend-svc` | Same namespace only | Expands via search domain |
| Namespace-qualified | `backend-svc.lab-27-network` | Any namespace | Does not require `.svc.cluster.local` |
| FQDN | `backend-svc.lab-27-network.svc.cluster.local` | Any namespace, any cluster | Always unambiguous |

**How short name resolution works:**
Each pod's `/etc/resolv.conf` contains search domains:
```
search lab-27-network.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
```

When you query `backend-svc`, the resolver appends each search domain in order until one resolves:
1. `backend-svc.lab-27-network.svc.cluster.local` — found, returns the ClusterIP

When you query `backend` from the same namespace:
1. `backend.lab-27-network.svc.cluster.local` — not found (NXDOMAIN)
2. `backend.svc.cluster.local` — not found
3. `backend.cluster.local` — not found
4. `backend` (as a global name) — not found
Result: DNS resolution fails.

**Best practice:** Use FQDNs or namespace-qualified names in configuration that may be used across namespaces. Use short names only for in-namespace communication where the service name is well-known.

---

## Summary Triage Table

| Symptom | First command | What to look for | Likely cause |
|---------|--------------|-----------------|-------------|
| Connection timeout | `kubectl get endpoints <svc>` | `<none>` in ENDPOINTS | Selector mismatch |
| Connection refused | `kubectl describe svc <svc>` | targetPort value | Wrong targetPort |
| `bad address` or DNS error | `kubectl exec -- nslookup <name>` | NXDOMAIN | Wrong service name in URL |
| All of the above | `kubectl get endpoints -n <ns>` | Compare all services | Survey first |
