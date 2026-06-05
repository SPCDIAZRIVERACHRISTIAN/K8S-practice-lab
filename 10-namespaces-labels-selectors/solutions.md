# Solutions — 10 Namespaces, Labels, and Selectors

---

## What namespaces do

Namespaces are a virtual partitioning of the cluster. They scope most Kubernetes objects (Pods, Deployments, Services, ConfigMaps, etc.) so that the same name can exist independently in two namespaces.

Objects that are NOT namespaced (cluster-scoped):
- Nodes
- PersistentVolumes
- StorageClasses
- ClusterRoles / ClusterRoleBindings
- Namespaces themselves

Objects that ARE namespaced (almost everything else):
- Pods, Deployments, Services, ConfigMaps, Secrets, ServiceAccounts, etc.

---

## Default namespace behavior

When you run `kubectl get pods` without `-n`, kubectl uses the namespace from your current kubeconfig context. For a freshly created kind cluster, that is `default`.

This is why "I can't see my pods" is a common issue — the pods are in a different namespace.

---

## Labels vs annotations

| | Labels | Annotations |
|--|--------|-------------|
| Purpose | Identification and selection | Metadata for humans and tooling |
| Used by | Selectors (ReplicaSets, Services, NetworkPolicies) | Not used by Kubernetes internals for selection |
| Key rules | Limited characters, max 63 chars for name | More permissive — can hold URLs, JSON, etc. |
| Examples | `app=frontend`, `env=production` | `contact=team-a@example.com`, runbook URLs |

Labels are queried by Kubernetes controllers. Annotations are not. If you need to select resources by a property, use a label. If you need to attach metadata that has no selection purpose, use an annotation.

---

## What happens when you remove a label from a pod

When you remove the `app` label that the ReplicaSet selector uses:

1. The pod becomes invisible to the ReplicaSet (the selector no longer matches it)
2. The ReplicaSet sees only N-1 pods matching its selector
3. The ReplicaSet creates a new replacement pod to reach the desired count
4. You now have N+1 pods total: N from the ReplicaSet + 1 orphan

The orphan pod is still running but no longer owned. It will not be counted, managed, or cleaned up by the ReplicaSet.

When you add the label back:
1. The ReplicaSet sees N+1 pods matching its selector
2. It is above desired count — it deletes one pod
3. You are back to N pods

This exercise demonstrates exactly how ReplicaSet ownership works. Labels are the only ownership mechanism.

---

## Label selector syntax

```bash
# Exact match
kubectl get pods -l app=frontend

# Multiple labels (AND logic)
kubectl get pods -l app=frontend,env=production

# Key exists (any value)
kubectl get pods -l app

# Key does not exist
kubectl get pods -l '!app'

# Set-based: value in a set
kubectl get pods -l 'env in (production, staging)'

# Set-based: value not in a set
kubectl get pods -l 'env notin (production)'
```

---

## Common mistakes

**Omitting -n and wondering where your resources are**
Always be explicit about namespace. Use `kubectl config set-context --current --namespace=<ns>` to change your default namespace for the session.

**Using labels for data that should be annotations**
Labels have strict character rules and are intended for selection. Storing long strings, email addresses, or URLs in labels works but is bad practice.

**Forgetting that label changes to a running pod do not propagate back to the spec**
If you add a label to a pod with `kubectl label pod`, that change is on the live pod object only. The Deployment's pod template is not updated. New pods created by the ReplicaSet will not have that extra label.
