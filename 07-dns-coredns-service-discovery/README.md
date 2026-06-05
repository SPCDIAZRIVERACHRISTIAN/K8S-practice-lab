# 07 — DNS and CoreDNS Service Discovery

**Goal:** Use DNS to reach a backend service from a frontend pod. Understand short names, the service.namespace form, and the full FQDN. Inspect CoreDNS and understand how cluster DNS is structured.

**What this lab teaches:**
- How CoreDNS resolves Kubernetes Service names
- The three DNS forms: short name, `service.namespace`, full FQDN
- When each form works and when it fails
- How to inspect CoreDNS pods and configuration
- How to diagnose DNS failures from inside a pod

**Prerequisites:**
- Completed lab 06
- kind cluster running

**What you will build:**

```
lab-07-backend namespace         lab-07-dns namespace
└── backend (nginx)          ←── frontend pod (busybox, runs curl)
    └── backend-service
```

The two namespaces are intentional. They force you to use the correct DNS form to reach a service across namespace boundaries.

**Files:**

| File | Purpose |
|------|---------|
| `manifests/backend-deployment.yaml` | nginx backend in `lab-07-backend` namespace |
| `manifests/backend-service.yaml` | ClusterIP Service named `backend` in `lab-07-backend` |
| `manifests/frontend-pod.yaml` | busybox pod in `lab-07-dns` for DNS testing |
| `commands.md` | Lab commands with observation prompts |
| `notes.md` | Workbook |
| `solutions.md` | DNS explanations and expected outputs |
| `cleanup.sh` | Deletes both namespaces |

**Success criteria:**
- [ ] Create both namespaces and apply all manifests
- [ ] Exec into the frontend pod and try all three DNS forms
- [ ] Explain why `backend` alone fails from `lab-07-dns`
- [ ] Confirm that `backend.lab-07-backend` and the full FQDN both resolve
- [ ] Inspect CoreDNS pods and locate the CoreDNS ConfigMap
- [ ] Explain what the cluster DNS domain is

**Estimated difficulty:** Medium

---

## Steps

### 1. Create both namespaces

```bash
kubectl create namespace lab-07-backend
kubectl create namespace lab-07-dns
```

### 2. Apply all manifests

```bash
kubectl apply -f manifests/backend-deployment.yaml
kubectl apply -f manifests/backend-service.yaml
kubectl apply -f manifests/frontend-pod.yaml
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

**Next lab:** `08-ingress-and-gateway-api-intro`
