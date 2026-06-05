# Solutions — 07 DNS and CoreDNS Service Discovery

---

## The three DNS forms

For a Service named `backend` in namespace `lab-07-backend`:

| Form | Example | When it works |
|------|---------|--------------|
| Short name | `backend` | Only from pods in the same namespace (`lab-07-backend`) |
| Service + namespace | `backend.lab-07-backend` | From any namespace in the cluster |
| Full FQDN | `backend.lab-07-backend.svc.cluster.local` | From any namespace — most explicit and unambiguous |

**The short name works due to the search domain.** When a pod queries `backend`, the resolver appends search domains from `/etc/resolv.conf` in order. If the pod is in `lab-07-dns`, the search list includes `lab-07-dns.svc.cluster.local` first. So `backend` expands to `backend.lab-07-dns.svc.cluster.local` — which does not exist. The lookup fails.

When the pod is in `lab-07-backend`, `backend` expands to `backend.lab-07-backend.svc.cluster.local` — which does exist.

---

## What /etc/resolv.conf looks like inside a pod

```
nameserver 10.96.0.10
search lab-07-dns.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```

- `nameserver` points to the CoreDNS Service ClusterIP (typically `10.96.0.10`)
- `search` lists the suffixes tried in order when a name without dots is queried
- `ndots:5` means: if a name has fewer than 5 dots, try appending search domains first

`backend.lab-07-backend` has one dot. Because `ndots:5` requires 5 dots before the name is tried as-is, the resolver first tries `backend.lab-07-backend.lab-07-dns.svc.cluster.local` (fails), then `backend.lab-07-backend.svc.cluster.local` (succeeds). This is why the two-part form resolves — it eventually matches the correct FQDN after trying the search list.

The full FQDN `backend.lab-07-backend.svc.cluster.local` has 4 dots — still less than 5. With `ndots:5`, it still tries search domains first before the name as-is. In practice it resolves correctly, but the FQDN is the most explicit and clearest form for cross-namespace references.

---

## CoreDNS

CoreDNS runs as a Deployment in `kube-system` with the label `k8s-app=kube-dns`. Its ClusterIP is the DNS server injected into every pod's `/etc/resolv.conf`.

The CoreDNS ConfigMap (`kubectl get configmap coredns -n kube-system -o yaml`) contains a `Corefile` that configures:
- The cluster domain (`.cluster.local`)
- Kubernetes plugin (resolves service DNS from the API server)
- Forward plugin (forwards external queries to the node's DNS resolver)
- Health, cache, and logging plugins

---

## Common mistakes

**Assuming short names work across namespaces**
The most common DNS mistake in Kubernetes. A service `database` in namespace `data` is NOT reachable as `database` from a pod in namespace `app`. Use `database.data` or the full FQDN.

**Relying on `nslookup` succeeding but `wget` failing**
DNS resolution success means the name resolves to an IP. It does not mean the service is reachable (the pods might be down, the port might be wrong, or a NetworkPolicy might block it). Always test end-to-end with an actual request.

**Forgetting that CoreDNS is just another pod**
CoreDNS can crash or be overloaded. If pods suddenly cannot resolve service names, check `kubectl get pods -n kube-system` for CoreDNS pod status.
