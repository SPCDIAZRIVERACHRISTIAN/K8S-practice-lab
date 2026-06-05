# 17 — StatefulSets

**Goal:** Deploy a StatefulSet with volumeClaimTemplates and a headless Service. Observe ordered pod startup, stable pod identity, stable DNS names, and that PVCs outlive their pods. Scale up and down and watch pod ordering. Delete a pod and confirm it comes back with the same name and same PVC.

**What this lab teaches:**
- What problems a StatefulSet solves that a Deployment cannot
- How pods get stable, ordered names (web-0, web-1, web-2)
- How a headless Service provides stable DNS per pod
- What volumeClaimTemplates does: one PVC per pod, bound to that pod's identity
- How scaling works in order (up: 0, 1, 2 — down: 2, 1, 0)
- Why PVCs are NOT deleted when a StatefulSet pod is deleted

**Prerequisites:**
- Completed lab 16
- kind cluster running

**What you will build:**

```
lab-17-statefulsets namespace
├── web (headless Service)
└── web (StatefulSet, 3 replicas)
    ├── web-0  → PVC: data-web-0  → /data/index.html
    ├── web-1  → PVC: data-web-1  → /data/index.html
    └── web-2  → PVC: data-web-2  → /data/index.html
```

Each pod is reachable by its own DNS name:
```
web-0.web.lab-17-statefulsets.svc.cluster.local
web-1.web.lab-17-statefulsets.svc.cluster.local
web-2.web.lab-17-statefulsets.svc.cluster.local
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/headless-service.yaml` | Headless Service (clusterIP: None) for StatefulSet DNS |
| `manifests/statefulset.yaml` | nginx StatefulSet with volumeClaimTemplates |
| `commands.md` | Lab commands |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes the namespace and PVCs |

**Success criteria:**
- [ ] Deploy the StatefulSet and observe pods starting in order: web-0, then web-1, then web-2
- [ ] Write a unique file to each pod's PVC (so you can tell them apart)
- [ ] Verify each pod has its own stable DNS name via the headless Service
- [ ] Delete web-1 and confirm it comes back as web-1 with the same PVC and data
- [ ] Scale from 3 to 5 and observe pods added in order (web-3, web-4)
- [ ] Scale from 5 to 2 and observe pods removed in reverse order (web-4, web-3)
- [ ] Confirm that the PVCs for removed pods are NOT deleted

**Estimated difficulty:** Medium

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-17-statefulsets
```

### 2. Apply the headless Service and StatefulSet

```bash
kubectl apply -f manifests/headless-service.yaml
kubectl apply -f manifests/statefulset.yaml
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

**Next phase:** `18-rbac-serviceaccounts` (coming in Phase 5)
