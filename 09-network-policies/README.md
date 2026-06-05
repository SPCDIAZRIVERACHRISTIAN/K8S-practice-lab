# 09 — Network Policies

**Goal:** Create a separate kind cluster with Calico as the CNI. Apply a deny-all NetworkPolicy, verify traffic is blocked, then allow only pods with a specific label. Confirm the policy is enforced.

**What this lab teaches:**
- Why kind's default CNI does not enforce NetworkPolicy
- How to create a kind cluster with Calico as the CNI
- How a deny-all NetworkPolicy isolates a pod
- How to write ingress rules that allow specific sources
- How to verify NetworkPolicy enforcement from both allowed and blocked pods

**Prerequisites:**
- Completed lab 06 (Services)
- Docker running
- kind and kubectl installed
- Internet access to pull Calico manifests

**Important — This lab uses its own cluster**

This lab does NOT use the shared `my-first-cluster`. It creates a separate kind cluster named `netpol-lab` with Calico as the CNI. This is required because kind's default CNI (kindnet) does not enforce NetworkPolicy.

The cleanup script for this lab deletes only the `netpol-lab` cluster. Your main cluster is not affected.

**What you will build:**

```
netpol-lab cluster
└── lab-09-netpol namespace
    ├── backend (nginx) ← only reachable by app=frontend
    ├── frontend-pod    (allowed to reach backend)
    └── other-pod       (blocked from reaching backend)

NetworkPolicies:
  netpol-deny-all-ingress  → deny all ingress to backend
  netpol-allow-frontend    → allow ingress from app=frontend
```

**Files:**

| File | Purpose |
|------|---------|
| `calico-kind-config.yaml` | kind cluster config with kindnet disabled |
| `scripts/install-calico.sh` | Applies Calico manifests and waits for ready |
| `manifests/namespace.yaml` | lab-09-netpol namespace |
| `manifests/backend-deployment.yaml` | nginx backend |
| `manifests/backend-service.yaml` | ClusterIP Service for backend |
| `manifests/frontend-pod.yaml` | busybox pod labeled app=frontend |
| `manifests/other-pod.yaml` | busybox pod labeled app=other |
| `manifests/netpol-deny-all-ingress.yaml` | Deny all ingress to backend pods |
| `manifests/netpol-allow-frontend.yaml` | Allow ingress from app=frontend only |
| `commands.md` | Lab commands |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes the netpol-lab cluster |

**Success criteria:**
- [ ] Create the `netpol-lab` cluster with Calico installed
- [ ] Verify Calico pods are running in `calico-system`
- [ ] Apply all workloads and confirm traffic works before any policy
- [ ] Apply deny-all: verify BOTH frontend-pod and other-pod are blocked
- [ ] Apply allow-frontend: verify frontend-pod is allowed, other-pod is still blocked
- [ ] Explain why kind's default CNI cannot be used for this lab

**Estimated difficulty:** Medium/Hard

---

## Steps

### 1. Create the netpol-lab cluster

```bash
kind create cluster --config calico-kind-config.yaml
```

### 2. Install Calico

```bash
./scripts/install-calico.sh
```

### 3. Apply all workloads

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/backend-deployment.yaml
kubectl apply -f manifests/backend-service.yaml
kubectl apply -f manifests/frontend-pod.yaml
kubectl apply -f manifests/other-pod.yaml
```

### 4. Work through the commands

Open `commands.md` and run each command.

### 5. Fill in your notes

Open `notes.md` and answer every question.

### 6. Clean up — this deletes the netpol-lab cluster

```bash
./cleanup.sh
```

---

**Next phase:** `10-namespaces-labels-selectors` (coming in Phase 3)
