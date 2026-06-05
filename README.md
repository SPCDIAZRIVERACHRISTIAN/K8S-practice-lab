# K8S Practice Lab

A hands-on Kubernetes training lab structured toward CKA-level skill. Every lab forces you to run commands, observe behavior, break something, fix it, and explain the concept in your own words.

This is not a tutorial where the answers are given. It is a practice environment.

---

## Prerequisites

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- Docker running
- Linux or macOS shell

---

## Create the kind cluster

```bash
kind create cluster --config 00-kind-cluster/kind-config.yaml
```

Verify it is running:

```bash
kind get clusters
kubectl get nodes
```

> Lab 09 uses a separate cluster. See `09-network-policies/README.md`.

---

## How to run labs

See [HOW_TO_USE_THIS_REPO.md](HOW_TO_USE_THIS_REPO.md) for the full workflow.

Short version: read the lab `README.md`, run `commands.md`, fill in `notes.md`, run the break/fix, check `solutions.md`, run `cleanup.sh`.

---

## How to clean up any lab

Every lab has a `cleanup.sh`. Run it from inside the lab folder:

```bash
./cleanup.sh
```

---

## Reset notes for sharing

Before sharing or publishing the repo, reset all `notes.md` files to blank templates:

```bash
./scripts/reset-notes.sh
```

Or without the confirmation prompt:

```bash
./scripts/reset-notes.sh --yes
```

---

## Cluster Architecture

![Kubernetes Cluster Diagram](assets/cluster-diagram.png)

---

## Lab Roadmap

| # | Folder | Topic | Difficulty | CKA Domain | Status |
|---|--------|-------|------------|------------|--------|
| 00 | `00-kind-cluster` | First multi-node cluster with kind | Beginner | Cluster Arch | ✅ |
| 01 | `01-pods` | Pods, lifecycle, logs, exec | Beginner | Workloads | ✅ |
| 02 | `02-deployments-replicasets` | Deployments, ReplicaSets, self-healing | Easy | Workloads | ✅ |
| 03 | `03-rollouts-rollbacks` | Rolling updates, rollback, history | Easy | Workloads | ✅ |
| 04 | `04-configmaps-secrets-env` | ConfigMaps, Secrets, env injection | Easy | Workloads | ✅ |
| 05 | `05-healthchecks-probes` | Readiness, liveness probes | Medium | Workloads | ✅ |
| 06 | `06-services-clusterip-nodeport` | ClusterIP, NodePort, endpoints | Easy | Networking | ✅ |
| 07 | `07-dns-coredns-service-discovery` | CoreDNS, service DNS, FQDN | Medium | Networking | ✅ |
| 08 | `08-ingress-and-gateway-api-intro` | Ingress controller, routing, Gateway API | Medium | Networking | ✅ |
| 09 | `09-network-policies` | NetworkPolicy, deny-all, allow rules | Medium/Hard | Networking | ✅ |
| 10 | `10-namespaces-labels-selectors` | Namespaces, labels, selectors | Easy | Workloads | ✅ |
| 11 | `11-resource-requests-limits` | CPU/memory, QoS, OOMKilled | Medium | Workloads | ✅ |
| 12 | `12-node-selectors-affinity-taints-tolerations` | Node scheduling, taints, tolerations | Medium | Workloads | ✅ |
| 13 | `13-daemonsets-jobs-cronjobs` | DaemonSet, Job, CronJob | Easy | Workloads | ✅ |
| 14 | `14-autoscaling-hpa-basics` | HPA, metrics-server, CPU scaling | Medium | Workloads | ✅ |
| 15 | `15-volumes-emptydir-hostpath` | emptyDir, hostPath, persistence | Easy | Storage | ✅ |
| 16 | `16-pv-pvc-storageclass` | PV, PVC, StorageClass, provisioning | Medium | Storage | ✅ |
| 17 | `17-statefulsets` | StatefulSet, stable identity, PVCs | Medium | Storage | ✅ |
| 18 | `18-rbac-serviceaccounts` | RBAC, ServiceAccount, least privilege | Medium | Cluster Arch | ✅ |
| 19 | `19-security-contexts-admission-basics` | securityContext, Pod Security Admission | Medium | Cluster Arch | ✅ |
| 20 | `20-helm-kustomize` | Helm, Kustomize overlays | Medium | Cluster Arch | ✅ |
| 21 | `21-crds-operators-intro` | CRDs, custom resources, operators | Medium | Cluster Arch | ✅ |
| 22 | `22-kubeadm-theory-and-kind-mapping` | kubeadm, static pods, etcd, certs | Hard | Cluster Arch | ✅ |
| 23 | `23-backup-restore-etcd-concept-lab` | etcd backup/restore concepts | Hard | Cluster Arch | ✅ |
| 24 | `24-upgrades-and-node-maintenance` | cordon, drain, PDB, node maintenance | Hard | Cluster Arch | ✅ |
| 25 | `25-logs-events-describe-debug` | Observability toolkit | Medium | Troubleshooting | ✅ |
| 26 | `26-troubleshoot-workloads` | Broken deployments, fix scenarios | Hard | Troubleshooting | ✅ |
| 27 | `27-troubleshoot-networking` | Service routing, DNS, Ingress failures | Hard | Troubleshooting | ✅ |
| 28 | `28-troubleshoot-storage` | PVC failures, mount errors | Hard | Troubleshooting | ✅ |
| 29 | `29-troubleshoot-cluster-nodes` | Node issues, taints, resource pressure | Hard | Troubleshooting | ✅ |
| 30 | `30-cka-speed-basics` | Timed imperative kubectl drills | Exam-style | All | ✅ |
| 31 | `31-cka-speed-networking-storage` | Timed networking + storage tasks | Exam-style | All | ✅ |
| 32 | `32-cka-speed-troubleshooting` | Timed troubleshooting scenarios | Exam-style | Troubleshooting | ✅ |
| 33 | `33-mock-exam-01` | Full CKA mock exam (2 hours) | Exam-style | All | ✅ |
| 34 | `34-mock-exam-02-hard` | Harder CKA mock exam (2 hours) | Exam-style | All | ✅ |
| 99 | `99-capstone-microservice-platform` | End-to-end multi-service platform | Capstone | All | ✅ |

---

## CKA Domain Coverage

See [CKA_DOMAIN_MAP.md](CKA_DOMAIN_MAP.md) for the full domain mapping and recommended study passes.

---

## Resources

- [kubernetes-info.md](kubernetes-info.md) — Kubernetes concepts and component reference
- [HOW_TO_USE_THIS_REPO.md](HOW_TO_USE_THIS_REPO.md) — Lab workflow guide
- [CKA_DOMAIN_MAP.md](CKA_DOMAIN_MAP.md) — CKA domain coverage map

---

> `notes.md` files are intentionally blank question-based workbooks. They are meant to be filled in by you as you work through each lab. Do not look at `solutions.md` until you have attempted every question in `notes.md`.
