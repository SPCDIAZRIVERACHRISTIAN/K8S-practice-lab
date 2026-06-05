# 11 — Resource Requests and Limits

**Goal:** Configure CPU and memory requests and limits on pods. Observe the three QoS classes. Create an unschedulable pod with excessive requests, and trigger an OOMKill by setting a memory limit the container cannot stay within.

**What this lab teaches:**
- The difference between resource requests and limits
- How requests affect pod scheduling (node fit)
- How limits enforce runtime resource caps
- The three QoS classes: Guaranteed, Burstable, BestEffort
- What OOMKilled looks like and why it happens
- What an unschedulable pod looks like and how to diagnose it

**Prerequisites:**
- Completed lab 02
- kind cluster running

**What you will build:**

```
lab-11-resources namespace
├── pod-guaranteed    (requests == limits → Guaranteed QoS)
├── pod-burstable     (requests < limits  → Burstable QoS)
├── pod-besteffort    (no requests/limits → BestEffort QoS)
├── pod-unschedulable (requests 100Gi RAM → Pending forever)
└── pod-oom           (limit 15Mi, writes 20Mi to memory → OOMKilled)
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/pod-guaranteed.yaml` | Requests == limits (Guaranteed QoS) |
| `manifests/pod-burstable.yaml` | Requests < limits (Burstable QoS) |
| `manifests/pod-besteffort.yaml` | No requests or limits (BestEffort QoS) |
| `broken/pod-unschedulable.yaml` | Requests 100Gi memory — no node can fit this |
| `broken/pod-oom.yaml` | Memory limit 15Mi, container writes 20Mi — triggers OOMKill |
| `commands.md` | Lab commands |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes the lab namespace |

**Success criteria:**
- [ ] Apply all three QoS pods and confirm their QoS class with `kubectl describe`
- [ ] Apply the unschedulable pod, observe Pending, and diagnose with `kubectl describe`
- [ ] Apply the OOM pod and observe the RESTARTS counter increase and OOMKilled status
- [ ] Explain why removing requests makes a pod harder to schedule predictably
- [ ] Explain what happens to a BestEffort pod when the node runs out of memory

**Estimated difficulty:** Medium

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-11-resources
```

### 2. Apply the working pods

```bash
kubectl apply -f manifests/pod-guaranteed.yaml
kubectl apply -f manifests/pod-burstable.yaml
kubectl apply -f manifests/pod-besteffort.yaml
```

### 3. Apply the broken pods

```bash
kubectl apply -f broken/pod-unschedulable.yaml
kubectl apply -f broken/pod-oom.yaml
```

### 4. Work through the commands

Open `commands.md` and run each command.

### 5. Fill in your notes

Open `notes.md` and answer every question.

### 6. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `12-node-selectors-affinity-taints-tolerations`
