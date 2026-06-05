# 01 — Pods

**Goal:** Create, inspect, exec into, and delete a pod manually. Observe what happens when the image is broken. Understand that pods without a controller do not self-heal.

**What this lab teaches:**
- What a pod is and how it wraps a container
- The pod lifecycle: Pending → ContainerCreating → Running → Terminated
- How to read pod logs and exec into a running pod
- What `ImagePullBackOff` looks like and how to fix it
- Why deleting a pod does not bring it back (no controller)

**Prerequisites:**
- Completed lab 00 — kind cluster is running
- `kubectl` pointed at `kind-kind`

**What you will build:**

```
lab-01-pods namespace
└── nginx-pod   (single pod, no controller)
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/nginx-pod.yaml` | A working nginx pod |
| `broken/bad-image-pod.yaml` | A pod with a nonexistent image tag |
| `commands.md` | Lab commands with observation prompts |
| `notes.md` | Workbook — answer after running the lab |
| `solutions.md` | Expected outputs and explanations |
| `cleanup.sh` | Deletes the lab namespace |

**Success criteria:**
- [ ] Create the namespace and apply the pod manifest
- [ ] Use `kubectl get pods`, `kubectl describe pod`, and `kubectl logs` to inspect it
- [ ] Exec into the running pod and run a command inside the container
- [ ] Apply the broken image pod and observe `ImagePullBackOff`
- [ ] Fix the broken pod by editing the image tag
- [ ] Delete the working pod and confirm it does not come back
- [ ] Explain why a deleted pod stays gone without a Deployment

**Estimated difficulty:** Beginner

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-01-pods
```

### 2. Apply the working pod

```bash
kubectl apply -f manifests/nginx-pod.yaml
```

### 3. Work through the commands

Open `commands.md` and run each command in order.

### 4. Apply the broken pod and observe

```bash
kubectl apply -f broken/bad-image-pod.yaml
```

### 5. Fill in your notes

Open `notes.md` and answer every question before moving on.

### 6. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `02-deployments-replicasets`
