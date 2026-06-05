# 14 — Autoscaling: HPA Basics

**Goal:** Install metrics-server in kind, create an HPA for a Deployment, generate CPU load, and watch the HPA scale the Deployment up. Then remove CPU requests and observe the HPA fail to calculate metrics.

**What this lab teaches:**
- What the HPA (HorizontalPodAutoscaler) does
- Why metrics-server is required for CPU-based HPA
- How CPU requests are used to calculate a utilization percentage
- What happens when a pod has no CPU requests (HPA cannot function)
- How to read HPA status and understand its scaling decisions

**Prerequisites:**
- Completed labs 02 and 11
- kind cluster running
- Internet access to install metrics-server

**What you will build:**

```
lab-14-autoscaling namespace
└── php-apache (Deployment, 1 replica initially)
    └── HPA: scale between 1–5 replicas when CPU > 50%
```

Under load:
```
1 pod → 2 → 3 → up to 5 (as CPU utilization climbs)
```

**Files:**

| File | Purpose |
|------|---------|
| `scripts/install-metrics-server.sh` | Installs metrics-server with kind-compatible flags |
| `manifests/deployment.yaml` | Deployment with CPU requests set (required for HPA) |
| `manifests/hpa.yaml` | HPA targeting the Deployment at 50% CPU |
| `manifests/load-generator.yaml` | busybox pod that hammers the service with requests |
| `broken/deployment-no-requests.yaml` | Same Deployment but without CPU requests |
| `commands.md` | Lab commands |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes the namespace and metrics-server |

**Success criteria:**
- [ ] Install metrics-server and verify `kubectl top pods` works
- [ ] Apply the Deployment and HPA
- [ ] Start the load generator and watch `kubectl get hpa` show CPU climbing
- [ ] Observe the Deployment scale up as CPU exceeds the target
- [ ] Stop load and observe scale-down after the cooldown period
- [ ] Apply the no-requests Deployment and observe HPA status show `<unknown>`

**Estimated difficulty:** Medium

---

## Steps

### 1. Install metrics-server

```bash
./scripts/install-metrics-server.sh
```

### 2. Create the namespace and apply Deployment + HPA

```bash
kubectl create namespace lab-14-autoscaling
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/hpa.yaml
```

### 3. Work through the commands

Open `commands.md` and run each command.

### 4. Apply the broken Deployment to see HPA failure

```bash
kubectl apply -f broken/deployment-no-requests.yaml
```

### 5. Fill in your notes

Open `notes.md` and answer every question.

### 6. Clean up

```bash
./cleanup.sh
```

---

**Next phase:** `15-volumes-emptydir-hostpath` (coming in Phase 4)
