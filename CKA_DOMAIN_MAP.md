# CKA Domain Map — Phase 0–2

This file maps each lab to the CKA exam domains it covers.

CKA domain weights:
- **Cluster Architecture, Installation & Configuration** — 25%
- **Services & Networking** — 20%
- **Workloads & Scheduling** — 15%
- **Storage** — 10%
- **Troubleshooting** — 30%

---

## Lab → Domain mapping

| Lab | Topic | Cluster Arch 25% | Networking 20% | Workloads 15% | Storage 10% | Troubleshooting 30% |
|-----|-------|:---:|:---:|:---:|:---:|:---:|
| 00 | kind cluster setup | ✅ | | | | ✅ |
| 01 | Pods | ✅ | | ✅ | | ✅ |
| 02 | Deployments & ReplicaSets | | | ✅ | | ✅ |
| 03 | Rollouts & Rollbacks | | | ✅ | | ✅ |
| 04 | ConfigMaps & Secrets | | | ✅ | | ✅ |
| 05 | Health checks & Probes | | | ✅ | | ✅ |
| 06 | Services: ClusterIP & NodePort | | ✅ | | | ✅ |
| 07 | DNS & CoreDNS | ✅ | ✅ | | | ✅ |
| 08 | Ingress & Gateway API | | ✅ | | | ✅ |
| 09 | Network Policies | | ✅ | | | ✅ |
| 10 | Namespaces, Labels, Selectors | | | ✅ | | ✅ |
| 11 | Resource Requests & Limits | | | ✅ | | ✅ |
| 12 | Node Selectors, Affinity, Taints | ✅ | | ✅ | | ✅ |
| 13 | DaemonSets, Jobs, CronJobs | | | ✅ | | ✅ |
| 14 | HPA & Autoscaling Basics | | | ✅ | | ✅ |
| 15 | emptyDir & hostPath Volumes | | | | ✅ | ✅ |
| 16 | PV, PVC, StorageClass | | | | ✅ | ✅ |
| 17 | StatefulSets | | | ✅ | ✅ | ✅ |
| 18 | RBAC & ServiceAccounts | ✅ | | | | ✅ |
| 19 | Security Contexts & Pod Security Admission | ✅ | | | | ✅ |
| 20 | Helm & Kustomize | ✅ | | | | |
| 21 | CRDs & Operators Intro | ✅ | | | | |
| 22 | kubeadm Theory & kind Mapping | ✅ | | | | ✅ |
| 23 | etcd Backup & Restore | ✅ | | | | ✅ |
| 24 | Upgrades & Node Maintenance | ✅ | | | | ✅ |
| 25 | Logs, Events, Describe, Debug | | | | | ✅ |
| 26 | Troubleshoot Workloads | | | ✅ | | ✅ |
| 27 | Troubleshoot Networking | | ✅ | | | ✅ |
| 28 | Troubleshoot Storage | | | | ✅ | ✅ |
| 29 | Troubleshoot Cluster Nodes | ✅ | | ✅ | | ✅ |
| 30 | CKA Speed — Basics | ✅ | ✅ | ✅ | ✅ | ✅ |
| 31 | CKA Speed — Networking & Storage | | ✅ | | ✅ | ✅ |
| 32 | CKA Speed — Troubleshooting | | ✅ | ✅ | ✅ | ✅ |
| 33 | Mock Exam 01 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 34 | Mock Exam 02 Hard | ✅ | ✅ | ✅ | ✅ | ✅ |
| 99 | Capstone — Microservice Platform | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Recommended study passes

### First pass — build foundational understanding

Work through labs in order: 00 → 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09

Take your time. Write full notes. Do every break/fix exercise.

### Second pass — timed repetition

Repeat labs 01–09 from scratch without looking at `commands.md`. Time yourself. Goal: complete each lab in under 20 minutes.

### Exam-speed pass (after all phases complete)

Use the timed drill labs (30–32) and mock exams (33–34). Practice imperative kubectl commands. Aim for sub-10-minute completion on individual task types.

---

## Phase tracking

| Phase | Labs | Status |
|-------|------|--------|
| Phase 0 — Foundation | 00 | ✅ Complete |
| Phase 1 — Core Workloads | 01–05 | ✅ Complete |
| Phase 2 — Networking | 06–09 | ✅ Complete |
| Phase 3 — Scheduling | 10–14 | ✅ Complete |
| Phase 4 — Storage | 15–17 | ✅ Complete |
| Phase 5 — Security & Admin | 18–21 | ✅ Complete |
| Phase 6 — Cluster Lifecycle | 22–24 | ✅ Complete |
| Phase 7 — Observability & Troubleshooting | 25–29 | ✅ Complete |
| Phase 8 — CKA Drills & Mock Exams | 30–34 | ✅ Complete |
| Phase 9 — Capstone | 99 | ✅ Complete |
