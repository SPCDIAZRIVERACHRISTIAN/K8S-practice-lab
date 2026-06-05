# 16 — PersistentVolumes, PersistentVolumeClaims, and StorageClass

**Goal:** Create a PVC using kind's built-in StorageClass, mount it in a pod, write data, and verify the data survives pod deletion. Break the PVC by requesting a nonexistent StorageClass, observe it stay Pending, and fix it. Delete the PVC and observe the reclaim behavior.

**What this lab teaches:**
- The three-layer storage model: StorageClass → PersistentVolume → PersistentVolumeClaim
- How dynamic provisioning works (PVC created → PV auto-created by the provisioner)
- What access modes mean (ReadWriteOnce, ReadWriteMany, ReadOnlyMany)
- What reclaim policies mean (Retain vs Delete)
- Why a PVC in Pending state blocks a pod from starting
- How to diagnose a Pending PVC

**Prerequisites:**
- Completed lab 15
- kind cluster running (kind includes the `standard` StorageClass via local-path-provisioner)

**What you will build:**

```
lab-16-storage namespace
├── data-pvc   (PVC → triggers PV creation via local-path provisioner)
└── data-pod   (mounts data-pvc at /data, writes a file)
```

```
StorageClass: standard
  └── PVC: data-pvc (Pending → Bound once pod references it)
        └── PV: pvc-xxxx (auto-created by provisioner)
              └── Pod: data-pod (/data mountPath)
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/pvc.yaml` | PVC using the `standard` StorageClass |
| `manifests/pod.yaml` | Pod that mounts the PVC and writes data |
| `broken/pvc-wrong-storageclass.yaml` | PVC requesting a StorageClass that does not exist |
| `commands.md` | Lab commands |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes the namespace and observes PV reclaim |

**Success criteria:**
- [ ] Apply the PVC and observe it move from Pending to Bound
- [ ] Mount the PVC in a pod, write a file, delete the pod, recreate it — file persists
- [ ] Apply the broken PVC and observe it stay Pending indefinitely
- [ ] Use `kubectl describe pvc` to diagnose the problem
- [ ] Fix the StorageClass name and verify the PVC binds
- [ ] Delete the PVC and observe what happens to the PV

**Estimated difficulty:** Medium

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-16-storage
```

### 2. Inspect what StorageClasses exist

```bash
kubectl get storageclass
```

### 3. Apply the PVC and pod

```bash
kubectl apply -f manifests/pvc.yaml
kubectl apply -f manifests/pod.yaml
```

### 4. Work through the commands

Open `commands.md` and run each command.

### 5. Apply the broken PVC

```bash
kubectl apply -f broken/pvc-wrong-storageclass.yaml
```

### 6. Fill in your notes

Open `notes.md` and answer every question.

### 7. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `17-statefulsets`
