# Solutions — 22 kubeadm Theory & kind Mapping

---

## The four control plane components

| Component | Role |
|-----------|------|
| **kube-apiserver** | The front door. All kubectl commands, controllers, and kubelets talk to the API server. The only component that reads/writes etcd directly. Exposes the REST API. |
| **etcd** | The cluster's single source of truth. A distributed key-value store that holds all cluster state: pods, deployments, configmaps, secrets, nodes, etc. If etcd is lost without a backup, the cluster state is gone. |
| **kube-controller-manager** | Runs all built-in controllers in a single process: Deployment controller, ReplicaSet controller, Node controller, Job controller, etc. Each controller watches for resource changes and drives actual state toward desired state. |
| **kube-scheduler** | Watches for unscheduled pods (pods with no `spec.nodeName`) and assigns them to nodes based on resource requests, taints/tolerations, affinity rules, and node capacity. Does not start pods — that is kubelet's job. |

**kube-proxy** is NOT a control plane component. It runs on every node (as a DaemonSet) and manages iptables/ipvs rules to implement Service networking — routing traffic from ClusterIP to pod IPs.

**CoreDNS** is also not a control plane component. It runs as a Deployment in `kube-system` and provides cluster DNS.

---

## Static pods

A static pod is a pod whose manifest is a file on the node's filesystem, read directly by kubelet — not a YAML stored in the Kubernetes API. The kubelet monitors the static pod directory and manages those pod lifecycles locally.

**Key differences from regular pods:**

| | Static Pod | Regular Pod |
|--|-----------|-------------|
| Stored in | Node filesystem (`/etc/kubernetes/manifests/`) | etcd (via API server) |
| Created by | kubelet reading a file | API server accepting a request |
| Managed by | kubelet on that node | A controller (ReplicaSet, DaemonSet, Job) |
| `ownerReferences` | `Node/<nodename>` | A controller object |
| Visible in `kubectl get pods` | Yes (as a mirror pod) | Yes |
| Deleteable via kubectl | No — kubelet recreates it | Yes |

**Why are control plane components static pods?**

Because they must be able to start before the API server is running. During kubeadm init, the API server does not exist yet. The kubelet starts etcd and the API server from local manifest files. Once the API server is up, normal cluster operations can begin. Using static pods breaks the chicken-and-egg problem of bootstrapping.

**What happens when you delete a static pod?**

kubelet detects the pod is gone (or forcibly terminated), re-reads its manifest file, and immediately recreates the pod. The API server shows this as the same pod disappearing and reappearing within seconds. You cannot permanently delete a static pod with `kubectl delete` — to stop it, you must remove or rename its manifest file on disk.

---

## PKI structure

A Kubernetes cluster uses TLS everywhere. The PKI (Public Key Infrastructure) created by `kubeadm init` has this structure:

```
/etc/kubernetes/pki/
  ca.crt / ca.key                — Kubernetes root CA (signs all component certs)
  apiserver.crt / apiserver.key  — API server's TLS cert (presented to clients)
  apiserver-kubelet-client.crt   — API server uses this to authenticate with kubelets
  apiserver-etcd-client.crt      — API server uses this to authenticate with etcd
  front-proxy-ca.crt             — CA for extension API servers (aggregation layer)
  front-proxy-client.crt         — client cert for the aggregation layer
  sa.pub / sa.key                — Service Account token signing key pair

/etc/kubernetes/pki/etcd/
  ca.crt / ca.key                — etcd's own CA (separate from the Kubernetes CA)
  server.crt / server.key        — etcd server cert (for peer and client connections)
  peer.crt / peer.key            — etcd peer cert (for etcd-to-etcd cluster communication)
  healthcheck-client.crt         — used by liveness probes to check etcd health
```

**Why does etcd have its own CA?**

etcd is treated as a separate security boundary from the rest of Kubernetes. Compromising the Kubernetes CA does not automatically give access to etcd, because etcd's CA is independent. The API server uses `apiserver-etcd-client.crt` (signed by etcd's CA) to connect.

**Certificate expiry:**
- Component certs (apiserver, kubelet, etc.): 1 year by default
- CA certs: 10 years by default
- After ~1 year, `kubeadm certs renew all` must be run to renew component certs
- The CKA exam tests `kubeadm certs check-expiration` — memorize this command

---

## kubeconfig files

A kubeconfig file has three sections:

```yaml
clusters:
- name: my-cluster
  cluster:
    server: https://127.0.0.1:6443        # API server address
    certificate-authority-data: <base64>  # root CA cert — verify server identity

users:
- name: kubernetes-admin
  user:
    client-certificate-data: <base64>     # who am I
    client-key-data: <base64>             # prove it

contexts:
- name: kubernetes-admin@kubernetes
  context:
    cluster: my-cluster
    user: kubernetes-admin
    namespace: default                    # optional default namespace
```

**Which kubeconfig does each component use?**

| Component | kubeconfig |
|-----------|-----------|
| kubectl (you) | `~/.kube/config` (kind copied `admin.conf` here) |
| kube-controller-manager | `/etc/kubernetes/controller-manager.conf` |
| kube-scheduler | `/etc/kubernetes/scheduler.conf` |
| kubelet (control-plane) | `/etc/kubernetes/kubelet.conf` |
| kubelet (worker) | `/etc/kubernetes/kubelet.conf` |

etcd does not use a kubeconfig — it uses raw TLS cert/key flags.

---

## kubeadm init phases

```
kubeadm init
  ├── preflight          → checks OS, container runtime, ports, swap settings
  ├── certs              → generates /etc/kubernetes/pki/* (all TLS certs and keys)
  ├── kubeconfig         → generates /etc/kubernetes/*.conf (kubeconfig files)
  ├── etcd               → writes /etc/kubernetes/manifests/etcd.yaml (static pod)
  ├── control-plane      → writes apiserver, controller-manager, scheduler static pod manifests
  ├── kubelet-start      → writes /var/lib/kubelet/config.yaml, starts kubelet
  ├── upload-config      → stores kubeadm-config and kubelet-config in kube-system ConfigMaps
  ├── upload-certs       → stores certs as a Secret for HA control-plane join
  ├── mark-control-plane → taints control-plane node, adds role label
  ├── bootstrap-token    → creates a bootstrap token (for kubeadm join)
  └── addons             → installs CoreDNS and kube-proxy
```

**kubeadm join** (for worker nodes):

1. Worker reads `cluster-info` ConfigMap from `kube-public` namespace (public, no auth needed) to find the API server address
2. Worker authenticates with the bootstrap token
3. API server issues a kubelet client certificate
4. kubelet writes its kubeconfig using the new cert
5. Node registers with the API server
6. Control-plane taints and labels the node

**Bootstrap token format:** `<6-char-token-id>.<16-char-token-secret>`, e.g., `abcdef.0123456789abcdef`. Tokens expire after 24 hours by default.

---

## kind vs production kubeadm

| Aspect | kind | Production kubeadm |
|--------|------|--------------------|
| Bootstrap | kubeadm runs inside the kind container | kubeadm runs on a bare VM/metal |
| Container runtime | containerd inside Docker | containerd or CRI-O directly on host |
| Networking | Docker bridge (no real network) | Real network (AWS VPC, GCP VPC, etc.) |
| etcd | Single etcd in a static pod | Single or HA etcd (3 or 5 nodes) |
| API server access | `https://127.0.0.1:<random-port>` | `https://<load-balancer-IP>:6443` |
| Cert expiry | Same defaults | Same — but renewal automation is production-critical |
| Static pod location | Same — `/etc/kubernetes/manifests/` | Same |
| kubelet | Runs inside container | Runs on host OS as a systemd service |

Everything you observed in this lab is directly applicable to a production kubeadm cluster. The paths, file formats, certificate structure, and component behavior are identical.
