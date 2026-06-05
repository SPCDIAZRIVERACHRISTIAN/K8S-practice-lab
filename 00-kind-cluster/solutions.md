# Solutions — 00 First Multi-Node Cluster with kind

Read this after completing `notes.md`. Use it to check your understanding, not to skip the work.

---

## What kind actually creates

kind (Kubernetes in Docker) runs each Kubernetes node as a Docker container. The container runs a full Linux environment with `containerd` as the container runtime inside it. This means you have containers running inside containers — the outer containers are nodes, and the inner containers are your pods.

When you run `docker ps`, you see one Docker container per Kubernetes node.

---

## Control-plane vs worker nodes

**Control-plane node responsibilities:**
- Runs the API server (`kube-apiserver`) — the front door for all kubectl commands
- Runs the scheduler (`kube-scheduler`) — decides which node a pod lands on
- Runs the controller manager (`kube-controller-manager`) — watches the cluster and reconciles desired state vs actual state
- Runs `etcd` — the key-value store that holds all cluster state

**Worker node responsibilities:**
- Runs your application pods
- Runs `kubelet` — the agent that takes instructions from the control plane and manages pods on that node
- Runs `kube-proxy` — handles network routing rules for services

The control-plane node in kind has a taint: `node-role.kubernetes.io/control-plane:NoSchedule`. This prevents regular user pods from being scheduled on it unless they explicitly tolerate that taint.

---

## Expected output: kubectl get nodes

```
NAME                             STATUS   ROLES           AGE   VERSION
my-first-cluster-control-plane   Ready    control-plane   Xm    v1.X.X
my-first-cluster-worker          Ready    <none>          Xm    v1.X.X
my-first-cluster-worker2         Ready    <none>          Xm    v1.X.X
```

Workers show `<none>` for ROLES because the `worker` role label is not set by default in kind.

---

## Expected output: kubectl get pods -n kube-system

You should see pods similar to:

| Pod name prefix | What it does |
|----------------|-------------|
| `coredns-*` | DNS server for the cluster. Resolves service names to IPs. |
| `etcd-*` | The cluster database. Stores all API objects. Runs only on control-plane. |
| `kube-apiserver-*` | Accepts and validates all kubectl/API requests. Runs only on control-plane. |
| `kube-controller-manager-*` | Runs control loops (Deployment controller, etc). Runs only on control-plane. |
| `kube-proxy-*` | Manages iptables/ipvs rules for Service networking. Runs on every node. |
| `kube-scheduler-*` | Assigns pending pods to nodes. Runs only on control-plane. |
| `kindnet-*` | kind's CNI plugin. Handles pod-to-pod networking. Runs on every node. |
| `local-path-provisioner-*` | Provides dynamic PVC provisioning using host paths. |

---

## Why the API server URL returns 403

When you open the API server URL in a browser, the browser sends an unauthenticated HTTP request. The Kubernetes API server sees a request with no valid certificate or token. It treats this as `system:anonymous`.

By default, `system:anonymous` is not authorized to access most API endpoints. You get:

```json
{
  "kind": "Status",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "code": 403
}
```

The API server is not broken — it is correctly rejecting an unauthorized request. kubectl authenticates using the credentials in your kubeconfig (client certificate and key that kind sets up automatically).

---

## kubectl context behavior after deletion

When you delete a kind cluster, kind removes the cluster's entry from your kubeconfig. The context disappears. When you recreate the cluster, kind adds a new context.

If you delete the cluster manually with `docker rm`, kubectl may still have a stale context pointing to a cluster that no longer exists. Requests will fail with a connection refused error.

---

## Common mistakes

**Using `worker1` / `worker2` as role values in kind-config.yaml**
kind only supports `control-plane` and `worker` as node roles. Any other value causes an error.

**Forgetting `--config` when creating the cluster**
Running `kind create cluster` without a config creates a single-node cluster. You will see only one node in `kubectl get nodes`.

**Wrong context name**
If you created multiple kind clusters, `kubectl` may be pointed at the wrong one. Always check `kubectl config current-context` before running commands.
