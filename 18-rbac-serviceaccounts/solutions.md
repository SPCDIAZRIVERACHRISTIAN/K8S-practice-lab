# Solutions — 18 RBAC & ServiceAccounts

---

## What RBAC is and why it exists

Before RBAC, Kubernetes had no way to restrict what a pod or user could do with the API. Any process that could reach the API server could read secrets, modify deployments, or delete namespaces.

RBAC (Role-Based Access Control) adds authorization on top of authentication. It answers the question: "Even though I know who you are, are you allowed to do this?"

The RBAC model has four objects:
- **Role** — a set of permissions scoped to one namespace
- **ClusterRole** — a set of permissions that applies cluster-wide (or to non-namespaced resources)
- **RoleBinding** — grants a Role or ClusterRole to a subject, within one namespace
- **ClusterRoleBinding** — grants a ClusterRole to a subject across the entire cluster

---

## ServiceAccounts

Every pod runs as a ServiceAccount. If you do not specify one, Kubernetes assigns the `default` ServiceAccount in the pod's namespace.

The ServiceAccount's token is automatically mounted at:
```
/var/run/secrets/kubernetes.io/serviceaccount/
  token       — the JWT bearer token sent with every API request
  ca.crt      — the cluster's CA certificate, used to verify the API server's TLS cert
  namespace   — the namespace this pod is running in
```

When a pod calls `kubectl get pods`, it authenticates using the `token` file. The API server then runs RBAC authorization to decide whether the ServiceAccount is allowed to perform that action.

If the ServiceAccount has no Role/RoleBinding granting the permission, the API server returns HTTP 403 Forbidden. `kubectl` displays this as:
```
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:lab-18-rbac:lab-reader" cannot list resource "pods" in API group "" in the namespace "default"
```

---

## Role rules

A Role rule has three required fields:

```yaml
rules:
- apiGroups: [""]        # "" = core API group (Pod, Service, ConfigMap, Secret, etc.)
  resources: ["pods"]    # which resource type
  verbs: ["get", "list"] # which HTTP verbs / actions
```

**apiGroups:**
- `""` — core API group: Pod, Service, Endpoints, ConfigMap, Secret, Node, PersistentVolume, etc.
- `"apps"` — Deployment, ReplicaSet, DaemonSet, StatefulSet
- `"batch"` — Job, CronJob
- `"rbac.authorization.k8s.io"` — Role, RoleBinding, ClusterRole, ClusterRoleBinding

**Common verbs:** `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`, `deletecollection`

**Why can lab-reader list pods but not delete deployments?**

The Role only contains:
```yaml
resources: ["pods", "pods/log"]
verbs: ["get", "list", "watch"]
```

Deployments are not in this resource list, and `delete` is not in the verbs list. Both restrictions independently deny access.

---

## Role vs ClusterRole

| | Role | ClusterRole |
|--|------|-------------|
| Scope | One namespace | All namespaces or cluster-wide |
| Non-namespaced resources | Cannot grant (Nodes, PVs, etc.) | Can grant |
| Used with | RoleBinding (same namespace) | RoleBinding (namespace-scoped) or ClusterRoleBinding (cluster-wide) |

**ClusterRole + RoleBinding:** You can bind a ClusterRole with a RoleBinding, which scopes the permissions to just that one namespace. This is useful for reusing a permission set (e.g., the built-in `view` ClusterRole) without granting cluster-wide access.

**ClusterRole + ClusterRoleBinding:** Grants the permissions in every namespace. Use this for cluster administrators, monitoring agents (need to read from all namespaces), or operators.

---

## kubectl auth can-i — how to use it

```bash
# Basic: can the current user do X?
kubectl auth can-i list pods -n lab-18-rbac

# Impersonate a ServiceAccount
kubectl auth can-i list pods -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader

# Full audit of everything a ServiceAccount can do
kubectl auth can-i --list -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader
```

The `--as` flag uses the full ServiceAccount identity format:
```
system:serviceaccount:<namespace>:<serviceaccount-name>
```

This is not the same as the name alone. The full qualified name is what the API server sees when a pod authenticates.

**Why did the ServiceAccount fail to list pods in `default`?**

The Role is namespace-scoped. It was created in `lab-18-rbac`. Its permissions only apply inside `lab-18-rbac`. To list pods in `default`, you would need either:
- A separate Role + RoleBinding in `default`
- A ClusterRole + ClusterRoleBinding

---

## Break / Fix analysis

**Empty Role — why permissions change immediately:**

RBAC is evaluated at request time, not at binding creation time. When a request arrives at the API server, it reads the current state of Roles and RoleBindings from etcd. If the Role has no rules, there is nothing to grant, so all requests are denied. Updating the Role takes effect for the next request — no pod restart required.

**Wrong subject name — why access is still denied:**

A RoleBinding has three pieces:
1. The Role it references (what permissions)
2. The subject (who gets those permissions)
3. The namespace (where the binding lives)

If the subject name does not match the ServiceAccount making the request, the binding is never matched. The correct subject format is:
```yaml
subjects:
- kind: ServiceAccount
  name: lab-reader          # must match the SA name exactly
  namespace: lab-18-rbac    # must match the SA namespace exactly
```

**The three things to check when RBAC denies access:**
1. Does the Role/ClusterRole include the resource and verb?
2. Does the RoleBinding/ClusterRoleBinding reference that Role?
3. Does the binding's subject match the identity making the request (correct name AND namespace)?

All three must be correct. One wrong link in the chain = access denied.

---

## Common CKA RBAC mistakes

**Wrong apiGroup for Deployments:**
```yaml
# Wrong
apiGroups: [""]
resources: ["deployments"]

# Correct
apiGroups: ["apps"]
resources: ["deployments"]
```

**Forgetting pods/log as a sub-resource:**

Reading pod logs requires granting `pods/log` as a separate resource from `pods`.

**Using ClusterRoleBinding when you only need namespace scope:**

If you bind a ClusterRole with a ClusterRoleBinding, the subject gets that access in every namespace — a significant over-permission. Prefer RoleBinding when namespace scope is sufficient.

**Not knowing the ServiceAccount identity format:**

On the CKA, you may be asked to create a RoleBinding for a ServiceAccount and verify it. Always use:
```
system:serviceaccount:<namespace>:<name>
```
for the `--as` flag or for `subjects[].name` when writing YAML directly.

---

## Imperative kubectl commands (CKA exam speed)

```bash
# Create a ServiceAccount
kubectl create serviceaccount lab-reader -n lab-18-rbac

# Create a Role
kubectl create role pod-reader \
  --verb=get,list,watch \
  --resource=pods,pods/log \
  -n lab-18-rbac

# Create a RoleBinding
kubectl create rolebinding lab-reader-binding \
  --role=pod-reader \
  --serviceaccount=lab-18-rbac:lab-reader \
  -n lab-18-rbac

# Verify
kubectl auth can-i list pods -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader
```

These four commands (or their equivalents) cover the majority of RBAC questions on the CKA.
