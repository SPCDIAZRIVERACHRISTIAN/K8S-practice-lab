# 13 — DaemonSets, Jobs, and CronJobs

**Goal:** Create a DaemonSet that runs one pod per node, a Job that completes successfully, a CronJob that runs on a schedule, and break a Job's command to observe failure and forced rerun.

**What this lab teaches:**
- When to use a DaemonSet instead of a Deployment
- How a DaemonSet tracks nodes and ensures one pod per node
- How a Job runs a task to completion and tracks success/failure
- How to use `parallelism` and `completions` in a Job
- How a CronJob manages Job creation on a schedule
- How to suspend and resume a CronJob

**Prerequisites:**
- Completed lab 02
- kind cluster running with at least 2 worker nodes

**What you will build:**

```
lab-13-workloads namespace
├── log-collector (DaemonSet) → 1 pod per node
├── compute-job   (Job)       → runs to completion
├── broken-job    (Job)       → fails, observe backoffLimit
└── report-cron   (CronJob)   → creates a Job every minute
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/daemonset.yaml` | busybox DaemonSet — one pod per node |
| `manifests/job-working.yaml` | Job that echoes output and exits 0 |
| `manifests/cronjob.yaml` | CronJob scheduled every minute |
| `broken/job-broken-command.yaml` | Job with a command that exits non-zero |
| `commands.md` | Lab commands |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes the lab namespace |

**Success criteria:**
- [ ] Apply the DaemonSet and confirm one pod runs on each node (including workers)
- [ ] Scale the node count mentally: how many pods would a DaemonSet create on a 10-node cluster?
- [ ] Apply the working Job and verify it reaches `Completed`
- [ ] Inspect Job logs and confirm the output
- [ ] Apply the broken Job and observe it reach `BackoffLimitExceeded`
- [ ] Apply the CronJob and observe it create Jobs on schedule
- [ ] Suspend the CronJob and confirm no new Jobs are created
- [ ] Resume the CronJob

**Estimated difficulty:** Easy

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-13-workloads
```

### 2. Apply all manifests

```bash
kubectl apply -f manifests/daemonset.yaml
kubectl apply -f manifests/job-working.yaml
kubectl apply -f manifests/cronjob.yaml
```

### 3. Apply the broken Job

```bash
kubectl apply -f broken/job-broken-command.yaml
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

**Next lab:** `14-autoscaling-hpa-basics`
