# Kubernetes Reference

## What is a Cluster?

A Kubernetes cluster is a set of machines (nodes) that run containerized applications managed by Kubernetes. It consists of a **Control Plane** that manages the cluster state and one or more **Worker Nodes** that run the actual workloads.

---

## Control Plane Components

| Component | Description |
|-----------|-------------|
| **kube-api-server** | The front door to the cluster. All communication — from kubectl, nodes, and internal components — goes through it via REST API. |
| **etcd** | A distributed key-value store that holds the entire cluster state and configuration. The source of truth for Kubernetes. |
| **kube-scheduler** | Watches for newly created pods with no assigned node and selects the best node to run them based on resource availability and constraints. |
| **kube-controller-manager** | Runs controllers that regulate cluster state — node health, replication counts, endpoints, service accounts, and more. |
| **cloud-controller-manager** | Integrates with cloud provider APIs to manage cloud-specific resources like load balancers, storage volumes, and node lifecycle. |

---

## Worker Node Components

| Component | Description |
|-----------|-------------|
| **kubelet** | An agent running on every node. It receives pod specs from the API server and ensures the described containers are running and healthy. |
| **kube-proxy** | Maintains network rules on each node to allow communication to pods from inside or outside the cluster. |
| **CRI (Container Runtime Interface)** | The software responsible for actually running containers (e.g., containerd, CRI-O). The kubelet talks to it to start and stop containers. |

---

## Pods

The smallest deployable unit in Kubernetes. A pod wraps one or more containers that share the same network namespace and storage, and are always scheduled together on the same node.
