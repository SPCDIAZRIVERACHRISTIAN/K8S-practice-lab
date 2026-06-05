# 00 — First Multi-Node Cluster with kind

**Goal:** Create a local Kubernetes cluster using kind, inspect its nodes and system pods, understand control plane vs workers, and delete/recreate the cluster cleanly.

**What this lab teaches:**
- What kind is and how it uses Docker containers as cluster nodes
- The role of the control-plane node vs worker nodes
- How kubectl uses a context to talk to a specific cluster
- Where the Kubernetes system pods live and what they do
- Why the API server URL returns 403 in a browser

**Prerequisites:**
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- Docker running

**What you will build:**

```
my-first-cluster
├── control-plane node    (Docker container)
├── worker node           (Docker container)
└── worker node           (Docker container)
```

Inside the control-plane node, kind runs the Kubernetes control plane components as static pods:

```
kube-apiserver
kube-controller-manager
kube-scheduler
etcd
coredns
```

**Files:**

| File | Purpose |
|------|---------|
| `kind-config.yaml` | Cluster definition: 1 control-plane + 2 workers |
| `commands.md` | Ordered commands with observation prompts |
| `notes.md` | Workbook — answer the questions after running the lab |
| `solutions.md` | Expected outputs, explanations, common errors |
| `cleanup.sh` | Deletes the kind cluster |

**Success criteria:**
- [ ] Create the multi-node cluster from `kind-config.yaml`
- [ ] List all nodes and identify which is control-plane and which are workers
- [ ] List all `kube-system` pods and describe what at least 3 of them do
- [ ] Describe a node and locate its taints, capacity, and conditions
- [ ] Explain in one sentence why the API server URL returns 403 in a browser
- [ ] Delete and recreate the cluster without looking anything up

**Estimated difficulty:** Beginner

---

## Steps

### 1. Create the cluster

```bash
kind create cluster --config kind-config.yaml
```

### 2. Work through the commands

Open `commands.md` and run each command in order. Read the output carefully before moving to the next step.

### 3. Fill in your notes

Open `notes.md` and answer each question in your own words before moving on. Do not skip this.

### 4. Check your understanding

Open `solutions.md` after completing your notes to verify your observations.

### 5. Clean up

```bash
./cleanup.sh
```

Or manually:

```bash
kind delete cluster --name my-first-cluster
```

---

**Next lab:** `01-pods`
