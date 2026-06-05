# 12 — Node Selectors, Affinity, Taints, and Tolerations

**Goal:** Schedule pods to specific nodes using nodeSelector and node affinity. Apply a taint to a worker node and observe pods become Pending. Add a toleration and fix placement.

**What this lab teaches:**
- How nodeSelector forces a pod to a node with a specific label
- How node affinity provides more expressive scheduling rules (required vs preferred)
- What a taint is and how it repels pods without a matching toleration
- How the control-plane taint works and why user pods do not land there by default
- How to cordon a node without a taint

**Prerequisites:**
- Completed lab 02
- kind cluster running with at least 2 worker nodes

**What you will build:**

```
kind  (cluster name)
├── kind-control-plane  (tainted: NoSchedule — user pods stay off)
├── kind-worker         (labeled: disktype=ssd — target for ssd-pod)
└── kind-worker2        (tainted: dedicated=special:NoSchedule — repels most pods)
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/pod-nodeselector.yaml` | Pod targeting a node by label |
| `manifests/pod-node-affinity.yaml` | Pod using requiredDuringSchedulingIgnoredDuringExecution |
| `manifests/pod-preferred-affinity.yaml` | Pod using preferredDuringSchedulingIgnoredDuringExecution |
| `manifests/pod-with-toleration.yaml` | Pod that tolerates a custom taint |
| `commands.md` | Lab commands (mix of manifest apply + imperative kubectl) |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes namespace and removes node labels/taints added during the lab |

**Success criteria:**
- [ ] Label a worker node and schedule a pod to it via `nodeSelector`
- [ ] Verify the pod lands on the labeled node
- [ ] Apply a required node affinity rule and confirm scheduling
- [ ] Apply a taint to a worker and observe subsequent pods become Pending
- [ ] Add a toleration to a pod and confirm it schedules on the tainted node
- [ ] Remove the taint after the lab
- [ ] Identify and explain the control-plane taint

**Estimated difficulty:** Medium

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-12-scheduling
```

### 2. Work through the commands

Open `commands.md` — the lab mixes manifest applies with imperative `kubectl label` and `kubectl taint` commands. Follow the order carefully.

### 3. Fill in your notes

Open `notes.md` and answer every question.

### 4. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `13-daemonsets-jobs-cronjobs`
