# Solutions — 08 Ingress and Gateway API Introduction

---

## Ingress resource vs Ingress controller

The **Ingress resource** is a Kubernetes API object. It is just configuration — it says "route `/api` to `backend-svc:80`." It does nothing on its own.

The **Ingress controller** is a running workload (a Deployment) that watches Ingress resources in the cluster and actually implements the routing. ingress-nginx reads Ingress objects and dynamically generates nginx configuration from them.

If you create an Ingress resource with no controller installed, the resource is stored in etcd but nothing acts on it. Traffic will not be routed.

```
kubectl apply -f ingress.yaml
      ↓
Ingress object created in API server
      ↓
Ingress controller (nginx) detects the change
      ↓
nginx rewrites its upstream config
      ↓
Traffic to /api now routes to backend-svc
```

---

## Why the broken Ingress returns 503

The ingress-nginx controller reads the Ingress rule: "backend for `/api` is `backend-svc:9090`." It tries to connect to that service on port 9090. The Service exists but has no port 9090. The upstream is invalid. nginx returns a `503 Service Unavailable`.

The 503 comes from nginx inside the controller, not from your backend pods. The backend pods are healthy — they just never receive the request.

---

## 404 vs 503 from an Ingress

| Status | Meaning |
|--------|---------|
| 404 Not Found | The Ingress has no rule matching the request path |
| 503 Service Unavailable | The Ingress has a matching rule but the backend is unreachable |
| 502 Bad Gateway | The controller reached the backend but got an unexpected response |

---

## Diagnosing Ingress issues

1. `kubectl describe ingress <name> -n <ns>` — shows the routing rules as the controller sees them
2. `kubectl get endpoints <service> -n <ns>` — confirms pods are behind the service
3. `kubectl describe service <name> -n <ns>` — confirms the port mapping

For ingress-nginx specifically, the controller logs often show the exact upstream error:

```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=50
```

---

## The rewrite-target annotation

```yaml
nginx.ingress.kubernetes.io/rewrite-target: /
```

Without this annotation, a request to `/api/users` would be forwarded to the backend as `/api/users`. The backend might not have a route for `/api/users` and return a 404.

With `rewrite-target: /`, the ingress strips the matched prefix and forwards the request as `/`. This is useful when the backend serves on `/` internally but is exposed on a prefixed path externally.

---

## Ingress vs Gateway API

| | Ingress | Gateway API |
|--|---------|-------------|
| Maturity | Stable, CKA-tested | GA for core features as of K8s 1.28+ |
| Role separation | Single resource, single owner | Gateway (infra) + Route (app team) |
| Protocol support | HTTP/HTTPS | HTTP, gRPC, TCP, TLS |
| Traffic splitting | Via annotations (controller-specific) | Native in HTTPRoute |
| Portability | Annotations are controller-specific | Standard API across implementations |

The CKA exam currently tests Ingress. Gateway API is the direction Kubernetes is heading.

---

## Common mistakes

**Not installing the controller before applying Ingress resources**
Ingress resources without a controller are silently ignored. If routing does not work, always check if a controller is running.

**Using the wrong `ingressClassName`**
If you have multiple controllers (nginx + another), you must specify which one owns the Ingress. Wrong or missing `ingressClassName` means no controller picks it up.

**Forgetting that kind requires port mappings for Ingress to work from localhost**
The ingress-nginx kind deployment sets up hostPort bindings. If your kind cluster was not created with the right config, localhost:80 will not reach the controller. Check the ingress-nginx documentation for the correct kind-config.yaml for your version.
