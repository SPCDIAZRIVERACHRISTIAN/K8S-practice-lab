# 03 — Rollouts and Rollbacks

**Goal:** Perform a rolling update on a Deployment, break it with a bad image, observe the stalled rollout, and roll back to the previous working version.

**What this lab teaches:**
- How a rolling update works: new ReplicaSet scales up while old one scales down
- How to check rollout status and history
- What happens when a rollout stalls due to a bad image
- How to roll back to a previous revision

**Prerequisites:**
- Completed lab 02
- kind cluster running

**What you will build:**

```
lab-03-rollouts namespace
└── nginx-deployment (nginx:1.25)
    → update to nginx:1.26
    → update to nginx:badversion (stalls)
    → rollback to nginx:1.26
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/deployment.yaml` | nginx Deployment starting at nginx:1.25 |
| `commands.md` | Lab commands with observation prompts |
| `notes.md` | Workbook |
| `solutions.md` | Explanations and expected outputs |
| `cleanup.sh` | Deletes the lab namespace |

**Success criteria:**
- [ ] Deploy the initial Deployment and verify it is running
- [ ] Perform a successful rolling update to a new image version
- [ ] Observe the rollout history and identify revisions
- [ ] Push a broken image update and watch the rollout stall
- [ ] Roll back to the previous revision
- [ ] Explain why old ReplicaSets are kept after a rollout

**Estimated difficulty:** Easy

---

## Steps

### 1. Create the namespace and apply

```bash
kubectl create namespace lab-03-rollouts
kubectl apply -f manifests/deployment.yaml
```

### 2. Work through the commands

Open `commands.md` and run each command.

### 3. Fill in your notes

Open `notes.md` and answer every question.

### 4. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `04-configmaps-secrets-env`
