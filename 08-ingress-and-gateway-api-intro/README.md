# 08 — Ingress and Gateway API Introduction

**Goal:** Install an Ingress controller, expose two applications on different paths, break the Ingress routing with a wrong port, fix it, and understand the conceptual difference between Ingress and the Gateway API.

**What this lab teaches:**
- What an Ingress controller does and why it is separate from the Ingress resource
- How to route traffic to different services based on HTTP path
- How to diagnose a 503 caused by a wrong backend port in an Ingress rule
- The conceptual relationship between Ingress (current) and Gateway API (future direction)

**Prerequisites:**
- Completed lab 06
- kind cluster running
- Internet access to pull the ingress-nginx controller image

**What you will build:**

```
Client
  ↓
Ingress (nginx controller)
  ├── /       → frontend-svc:80 → nginx frontend pods
  └── /api    → backend-svc:80  → nginx backend pods
```

**Files:**

| File | Purpose |
|------|---------|
| `scripts/install-ingress-nginx.sh` | Installs ingress-nginx for kind and waits for it to be ready |
| `manifests/deployment-frontend.yaml` | nginx frontend Deployment |
| `manifests/deployment-backend.yaml` | nginx backend Deployment |
| `manifests/services.yaml` | ClusterIP Services for frontend and backend |
| `manifests/ingress.yaml` | Ingress resource routing `/` and `/api` |
| `broken/ingress-wrong-port.yaml` | Ingress with backend pointing to wrong service port |
| `fixed/ingress-correct-port.yaml` | Corrected Ingress |
| `commands.md` | Lab commands |
| `notes.md` | Workbook |
| `solutions.md` | Explanations |
| `cleanup.sh` | Deletes lab namespace and ingress-nginx namespace |

**Success criteria:**
- [ ] Install ingress-nginx controller and verify it is running
- [ ] Deploy frontend and backend, verify both are reachable via Ingress paths
- [ ] Apply the broken Ingress and observe a 503 on the `/api` path
- [ ] Use `kubectl describe ingress` and Ingress events to diagnose the problem
- [ ] Apply the fixed Ingress and confirm routing works
- [ ] Explain the difference between the Ingress resource and the Ingress controller

**Estimated difficulty:** Medium

---

## Steps

### 1. Install the ingress-nginx controller

```bash
./scripts/install-ingress-nginx.sh
```

Wait for it to complete before continuing.

### 2. Create the namespace and apply app manifests

```bash
kubectl create namespace lab-08-ingress
kubectl apply -f manifests/deployment-frontend.yaml
kubectl apply -f manifests/deployment-backend.yaml
kubectl apply -f manifests/services.yaml
kubectl apply -f manifests/ingress.yaml
```

### 3. Work through the commands

Open `commands.md` and run each command.

### 4. Apply the broken Ingress

```bash
kubectl apply -f broken/ingress-wrong-port.yaml
```

### 5. Fill in your notes

Open `notes.md` and answer every question.

### 6. Clean up

```bash
./cleanup.sh
```

---

## Gateway API: Conceptual Note

The Kubernetes Gateway API is the next-generation replacement for Ingress. It provides:
- Role-based separation: infrastructure owners manage Gateways, app teams manage Routes
- More expressive routing (header matching, traffic splitting, etc.)
- Better multi-protocol support

The core Ingress API is still widely used and the CKA exam tests it. Gateway API awareness is important context but full implementation is covered in a separate lab when it is stable in kind.

---

**Next lab:** `09-network-policies`
