# 15 — Volumes: emptyDir and hostPath

**Goal:** Mount an emptyDir volume into a pod, write data to it, delete the pod, and confirm the data is gone. Then use a hostPath volume and observe that node-local data outlives the pod — but does not follow it to another node.

**What this lab teaches:**
- What a volume is and how it differs from a container's writable layer
- How emptyDir lives and dies with the pod
- How hostPath binds a pod to a specific node's filesystem
- Why node-local storage is not durable cluster storage
- The risk of using hostPath in multi-node clusters

**Prerequisites:**
- Completed lab 11 (resource concepts)
- kind cluster running with at least 2 worker nodes

**What you will build:**

```
lab-15-volumes namespace
├── emptydir-pod   → writes to /data (emptyDir) → data gone when pod deleted
└── hostpath-pod   → writes to /data (hostPath) → data on node, survives pod
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/pod-emptydir.yaml` | Pod with an emptyDir volume |
| `manifests/pod-hostpath.yaml` | Pod with a hostPath volume bound to a specific worker |
| `commands.md` | Lab commands with observation prompts |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes the namespace |

**Success criteria:**
- [ ] Write a file to the emptyDir volume, delete the pod, confirm the file is gone on restart
- [ ] Write a file to the hostPath volume, delete the pod, confirm the file persists on the node
- [ ] Explain why hostPath would fail if the pod rescheduled to a different node
- [ ] Explain what emptyDir is useful for (shared scratch space between containers)
- [ ] Explain why neither volume type is appropriate for durable stateful workloads

**Estimated difficulty:** Easy

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-15-volumes
```

### 2. Apply both pods

```bash
kubectl apply -f manifests/pod-emptydir.yaml
kubectl apply -f manifests/pod-hostpath.yaml
```

### 3. Work through the commands

Open `commands.md` and run each command.

### 4. Fill in your notes

Open `notes.md` and answer every question.

### 5. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `16-pv-pvc-storageclass`
