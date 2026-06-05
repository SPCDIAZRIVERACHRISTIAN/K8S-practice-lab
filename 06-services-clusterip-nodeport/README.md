# 06 — Services: ClusterIP and NodePort

**Goal:** Expose a Deployment with a ClusterIP Service, then a NodePort Service. Break the Service selector, observe zero endpoints, and fix it.

**What this lab teaches:**
- Why pod IPs are unstable and why Services exist
- How a ClusterIP provides a stable internal address
- How a NodePort exposes a service on each node's IP
- How Service selectors connect a Service to pods
- How to inspect endpoints and diagnose a broken selector

**Prerequisites:**
- Completed lab 02
- kind cluster running

**What you will build:**

```
lab-06-services namespace
└── nginx-deployment (3 pods)
    ├── nginx-clusterip  (stable internal IP)
    └── nginx-nodeport   (exposed on each node port)
```

```
[within cluster] → ClusterIP:80 → pods
[from node]      → NodePort:3xxxx → ClusterIP:80 → pods
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/deployment.yaml` | nginx Deployment |
| `manifests/service-clusterip.yaml` | ClusterIP Service |
| `manifests/service-nodeport.yaml` | NodePort Service |
| `broken/service-bad-selector.yaml` | Service with a typo in the selector |
| `fixed/service-fixed-selector.yaml` | Corrected Service |
| `commands.md` | Lab commands |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes the lab namespace |

**Success criteria:**
- [ ] Create ClusterIP Service and verify pods appear as endpoints
- [ ] Access the Service from inside a pod using the ClusterIP
- [ ] Create NodePort Service and access nginx from outside the cluster
- [ ] Apply the broken selector Service and verify it has zero endpoints
- [ ] Diagnose the selector mismatch using `kubectl describe` and `--show-labels`
- [ ] Apply the fixed Service and confirm endpoints populate

**Estimated difficulty:** Easy

---

## Steps

### 1. Create the namespace and apply everything

```bash
kubectl create namespace lab-06-services
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service-clusterip.yaml
kubectl apply -f manifests/service-nodeport.yaml
```

### 2. Work through the commands

Open `commands.md` and run each command.

### 3. Apply the broken service

```bash
kubectl apply -f broken/service-bad-selector.yaml
```

### 4. Fill in your notes

Open `notes.md` and answer every question.

### 5. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `07-dns-coredns-service-discovery`
