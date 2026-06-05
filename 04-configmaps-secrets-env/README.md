# 04 — ConfigMaps, Secrets, and Environment Variables

**Goal:** Inject configuration into a pod using a ConfigMap and a Secret, observe what happens when a reference is missing, and fix both errors.

**What this lab teaches:**
- How ConfigMaps store non-sensitive configuration
- How Secrets store sensitive configuration (base64 encoded, not encrypted at rest by default)
- How to inject values as environment variables
- What `CreateContainerConfigError` looks like and how to diagnose it
- The difference between a missing key and a missing object

**Prerequisites:**
- Completed lab 02
- kind cluster running

**What you will build:**

```
lab-04-config namespace
├── app-config (ConfigMap)
├── app-secrets (Secret)
└── app-pod (reads from both)
```

**Files:**

| File | Purpose |
|------|---------|
| `manifests/configmap.yaml` | ConfigMap with app configuration |
| `manifests/secret.yaml` | Secret with fake credentials |
| `manifests/pod.yaml` | Pod that reads env vars from both |
| `broken/pod-missing-key.yaml` | Pod that references a nonexistent ConfigMap key |
| `broken/pod-missing-secret.yaml` | Pod that references a nonexistent Secret |
| `commands.md` | Lab commands with observation prompts |
| `notes.md` | Workbook |
| `solutions.md` | Explanations and expected outputs |
| `cleanup.sh` | Deletes the lab namespace |

**Success criteria:**
- [ ] Apply ConfigMap and Secret, verify they exist
- [ ] Apply the working pod and verify env vars are injected correctly
- [ ] Apply both broken pods and observe `CreateContainerConfigError`
- [ ] Use `kubectl describe pod` to identify exactly what is missing
- [ ] Fix both broken references
- [ ] Explain what base64 encoding in a Secret means (and does not mean)

**Estimated difficulty:** Easy

---

## Steps

### 1. Create the namespace

```bash
kubectl create namespace lab-04-config
```

### 2. Apply the ConfigMap and Secret first

```bash
kubectl apply -f manifests/configmap.yaml
kubectl apply -f manifests/secret.yaml
```

### 3. Apply the working pod

```bash
kubectl apply -f manifests/pod.yaml
```

### 4. Work through the commands

Open `commands.md` and run each command.

### 5. Apply the broken pods

```bash
kubectl apply -f broken/pod-missing-key.yaml
kubectl apply -f broken/pod-missing-secret.yaml
```

### 6. Fill in your notes

Open `notes.md` and answer every question.

### 7. Clean up

```bash
./cleanup.sh
```

---

**Next lab:** `05-healthchecks-probes`
