# 10 — Namespaces, Labels, and Selectors

**Goal:** Create resources across multiple namespaces with overlapping names, use labels to find resources across namespace boundaries, and experience what happens when you forget to specify a namespace.

**What this lab teaches:**
- How namespaces provide isolation within a cluster
- How labels and selectors work as the primary grouping mechanism
- How to filter resources using `-l` (label selectors) and `-n` (namespace)
- What annotations are and how they differ from labels
- How to query across all namespaces with `-A`

**Prerequisites:**
- Completed lab 02
- kind cluster running

**What you will build:**

```
lab-10-team-a namespace           lab-10-team-b namespace
├── frontend (Deployment)         ├── frontend (Deployment)
│   labels: team=a, tier=frontend │   labels: team=b, tier=frontend
└── backend  (Deployment)         └── (no backend)
    labels: team=a, tier=backend
```

Both namespaces have a Deployment named `frontend`. They coexist because namespaces isolate them.

**Files:**

| File | Purpose |
|------|---------|
| `manifests/namespaces.yaml` | Creates lab-10-team-a and lab-10-team-b |
| `manifests/team-a.yaml` | frontend + backend Deployments in lab-10-team-a |
| `manifests/team-b.yaml` | frontend Deployment in lab-10-team-b |
| `commands.md` | Lab commands with observation prompts |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes both namespaces |

**Success criteria:**
- [ ] Create both namespaces and apply all manifests
- [ ] List all Deployments across all namespaces with `-A`
- [ ] Demonstrate that two Deployments named `frontend` can coexist in different namespaces
- [ ] Filter pods by label across namespaces using `-l`
- [ ] Reproduce the "resource not found" error by querying the wrong namespace
- [ ] Add an annotation to a Deployment and describe the difference from a label

**Estimated difficulty:** Easy

---

## Steps

### 1. Apply all manifests

```bash
kubectl apply -f manifests/namespaces.yaml
kubectl apply -f manifests/team-a.yaml
kubectl apply -f manifests/team-b.yaml
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

**Next lab:** `11-resource-requests-limits`
