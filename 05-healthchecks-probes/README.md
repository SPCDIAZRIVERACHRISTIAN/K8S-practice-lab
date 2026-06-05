# 05 — Health Checks and Probes

**Goal:** Configure readiness and liveness probes on a Deployment. Break the probes to observe pods that are Running but never Ready, and watch the liveness probe trigger container restarts.

**What this lab teaches:**
- The difference between readinessProbe and livenessProbe
- How a failing readinessProbe removes pods from Service endpoints
- How a failing livenessProbe causes the container to restart
- What `CrashLoopBackOff` and a `0/1 Running` pod look like and mean
- Why a pod can be `Running` but not serving traffic

**Prerequisites:**
- Completed lab 02
- kind cluster running

**What you will build:**

```
lab-05-probes namespace
└── nginx-deployment
    └── pods with readiness + liveness probes
```

```
Client → Service → (only Ready pods get traffic)
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/deployment.yaml` | nginx Deployment with correct probes |
| `broken/deployment-bad-probe.yaml` | Deployment with misconfigured probes |
| `commands.md` | Lab commands with observation prompts |
| `notes.md` | Workbook |
| `solutions.md` | Explanations and expected outputs |
| `cleanup.sh` | Deletes the lab namespace |

**Success criteria:**
- [ ] Deploy with correct probes and verify all pods show `1/1 Running`
- [ ] Apply the broken probe deployment and observe `0/1 Running` (not Ready)
- [ ] Explain what the readiness probe failure means for a Service
- [ ] Observe liveness probe triggering container restarts (RESTARTS counter increases)
- [ ] Fix the probes and verify all pods become Ready

**Estimated difficulty:** Medium

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-05-probes
```

### 2. Apply the working Deployment

```bash
kubectl apply -f manifests/deployment.yaml
```

### 3. Work through the commands

Open `commands.md` and run each command.

### 4. Apply the broken probe Deployment

```bash
kubectl apply -f broken/deployment-bad-probe.yaml
```

### 5. Fill in your notes

Open `notes.md` and answer every question.

### 6. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `06-services-clusterip-nodeport`
