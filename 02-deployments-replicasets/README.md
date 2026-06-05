# 02 — Deployments and ReplicaSets

**Goal:** Create a Deployment, observe how the ReplicaSet provides self-healing, scale it up and down, and break the label selector to understand how pod ownership works.

**What this lab teaches:**
- How a Deployment creates and owns a ReplicaSet
- How a ReplicaSet watches pod count via label selectors
- Why pods owned by a Deployment come back after deletion
- What happens when selector and template labels do not match
- How to scale a Deployment

**Prerequisites:**
- Completed lab 01
- kind cluster running, kubectl context set

**What you will build:**

```
lab-02-deployments namespace
└── nginx-deployment
    └── ReplicaSet
        ├── nginx-pod-xxxxx
        ├── nginx-pod-xxxxx
        └── nginx-pod-xxxxx
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/deployment.yaml` | nginx Deployment with 3 replicas |
| `broken/deployment-bad-selector.yaml` | Deployment where selector does not match template labels |
| `commands.md` | Lab commands with observation prompts |
| `notes.md` | Workbook |
| `solutions.md` | Explanations and expected outputs |
| `cleanup.sh` | Deletes the lab namespace |

**Success criteria:**
- [ ] Create the Deployment and watch 3 pods appear
- [ ] Delete one pod manually and watch it recreate
- [ ] Scale the Deployment to 5, then to 2
- [ ] Observe the ReplicaSet that the Deployment created
- [ ] Apply the broken selector manifest and read the error
- [ ] Explain the relationship between Deployment → ReplicaSet → Pod

**Estimated difficulty:** Easy

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-02-deployments
```

### 2. Apply the Deployment

```bash
kubectl apply -f manifests/deployment.yaml
```

### 3. Work through the commands

Open `commands.md` and run each command.

### 4. Apply the broken selector

```bash
kubectl apply -f broken/deployment-bad-selector.yaml
```

### 5. Fill in your notes

Open `notes.md` and answer every question.

### 6. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `03-rollouts-rollbacks`
