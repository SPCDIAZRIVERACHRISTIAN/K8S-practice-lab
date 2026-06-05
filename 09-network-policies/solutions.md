# Solutions — 09 Network Policies

---

## Why a separate cluster is required

kind uses `kindnet` as its default CNI (Container Network Interface) plugin. kindnet provides pod-to-pod networking but does NOT implement the NetworkPolicy enforcement part of the CNI specification. When you apply a NetworkPolicy in a cluster running kindnet, it is stored in etcd but never enforced — all traffic still flows freely.

Calico is a CNI that does implement NetworkPolicy enforcement. When Calico is installed, it reads NetworkPolicy objects from the API server and programs iptables (or eBPF) rules on each node to enforce them.

---

## Default Kubernetes network model

Without NetworkPolicy, Kubernetes has a flat, open network:
- Any pod can reach any other pod in the cluster by IP
- Any pod can reach any Service
- There are no network-level restrictions by default

NetworkPolicy adds the ability to restrict this. But NetworkPolicy only works when the CNI enforces it.

---

## How deny-all works

```yaml
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  # no ingress rules listed
```

A NetworkPolicy that selects pods and declares `Ingress` as a policyType but has no ingress rules means: "allow no ingress traffic to these pods." The absence of rules is not an oversight — it is the policy. Zero ingress rules = zero allowed ingress.

---

## How allow-frontend works alongside deny-all

NetworkPolicies are additive. Multiple policies that select the same pod are unioned together.

With both policies applied:
- deny-all selects `app: backend` → deny all ingress
- allow-frontend selects `app: backend` → allow ingress from `app: frontend` on port 80

The result: only traffic from `app: frontend` on port 80 is allowed. All other ingress is denied.

There is no priority ordering. Policies do not override each other — they combine.

---

## Expected test results

| Test | Before policy | After deny-all | After allow-frontend |
|------|--------------|----------------|----------------------|
| frontend-pod → backend | success | blocked (timeout) | success |
| other-pod → backend | success | blocked (timeout) | blocked (timeout) |

---

## NetworkPolicy applies at the pod level, not the Service level

NetworkPolicy is enforced by iptables/eBPF rules on each node at the network interface level. The rules apply to traffic destined for a pod's IP address, regardless of whether the client is going through a Service ClusterIP or directly to the pod IP.

So even if you find the pod's IP and try to connect directly (bypassing the Service), the NetworkPolicy still blocks or allows it.

---

## Common mistakes

**Applying NetworkPolicy in a cluster that does not enforce it**
This is the most common mistake. The policy appears to apply (no error), but traffic is not affected. Always verify enforcement by testing actual connectivity.

**Confusing ingress/egress direction**
NetworkPolicy `ingress` controls traffic coming INTO the selected pod. `egress` controls traffic going OUT of the selected pod. A deny-all ingress policy does not affect what the selected pod can reach outbound.

**Forgetting that policies are namespace-scoped**
A NetworkPolicy in `lab-09-netpol` only affects pods in `lab-09-netpol`. It does not apply to pods in other namespaces. To restrict cross-namespace traffic, you need a `namespaceSelector` in the ingress rule.

**Expecting one policy to override another**
Policies do not override — they are additive. If you want to "update" a deny-all with an exception, you must add a separate allow policy. There is no deny-except syntax.
