# Solutions — 19 Security Contexts & Pod Security Admission

---

## securityContext fields

`securityContext` can be set at two levels: **pod level** (`.spec.securityContext`) and **container level** (`.spec.containers[].securityContext`). Container-level settings override pod-level settings when both are specified.

### Pod-level fields (apply to all containers)

| Field | What it does |
|-------|-------------|
| `runAsNonRoot: true` | Blocks any container whose image's default user is root (UID 0). Combined with `runAsUser`, forces a non-zero UID. |
| `runAsUser: 1000` | Sets the UID for all containers unless overridden at container level. |
| `runAsGroup: 3000` | Sets the primary GID for all containers. |
| `fsGroup: 2000` | Any volumes mounted to the pod have their group ownership changed to this GID. Useful for shared storage. |
| `seccompProfile: RuntimeDefault` | Applies the container runtime's default seccomp profile (usually blocks ~300 dangerous syscalls). |

### Container-level fields

| Field | What it does |
|-------|-------------|
| `allowPrivilegeEscalation: false` | Blocks `setuid` binary execution and the `no_new_privs` flag. Prevents `sudo` from gaining root even if run as non-root. |
| `readOnlyRootFilesystem: true` | Mounts the container's root filesystem as read-only. Any writes to `/` or its subtrees (except volume mounts) fail with "read-only file system". |
| `capabilities.drop: ["ALL"]` | Removes all Linux capabilities from the container. Capabilities are fine-grained privileges (e.g., `NET_BIND_SERVICE`, `SYS_ADMIN`) granted by default to containers. Dropping all prevents privilege abuse even as non-root. |
| `privileged: true` | Gives the container the same access as the host's root. This is the most dangerous setting — it bypasses nearly all container isolation. |

### Why /tmp is writable but / is not

`readOnlyRootFilesystem: true` marks the container's layered filesystem as read-only. But volume mounts are separate from the container filesystem — they are bind mounts from the host (or from emptyDir volumes) and are not affected by this setting. The secure pod mounts three emptyDir volumes at `/tmp`, `/var/cache/nginx`, and `/var/run` specifically to give nginx writable space while keeping the rest of the filesystem locked.

---

## Pod Security Admission (PSA)

PSA is an admission controller built into Kubernetes 1.25+ (replacing the deprecated PodSecurityPolicy). It enforces security profiles at the namespace level by inspecting pod specs at admission time.

### Three levels

| Level | What it allows |
|-------|---------------|
| `privileged` | No restrictions. Equivalent to no policy. |
| `baseline` | Blocks the most dangerous settings: `privileged: true`, `hostPID`, `hostNetwork`, `hostPath` volumes, `hostPort`, certain `capabilities.add`, running as root via `runAsUser: 0`. Does NOT require dropping all capabilities or `readOnlyRootFilesystem`. |
| `restricted` | Everything in baseline, plus: must drop ALL capabilities, must set `allowPrivilegeEscalation: false`, must not run as root (requires `runAsNonRoot: true` or explicit non-zero `runAsUser`), must have a `seccompProfile` set. |

### Three modes

| Mode | What it does |
|------|-------------|
| `enforce` | Pod is rejected if it violates the policy. The pod is NOT created. |
| `warn` | Pod IS created, but the API server returns a Warning header visible in `kubectl` output. |
| `audit` | Pod IS created, but a violation is recorded in the audit log. No user-visible warning. |

Modes are independent. A common pattern is `enforce: baseline` + `warn: restricted` + `audit: restricted` — this blocks truly dangerous pods while surfacing restricted violations for gradual policy tightening.

### Enabling PSA

PSA is configured via namespace labels:

```bash
kubectl label namespace lab-19-security \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest
```

Or in the namespace YAML:
```yaml
metadata:
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
```

The `enforce-version` field pins which Kubernetes version's policy definition to use. `latest` always uses the current version's definition.

---

## Broken pod analysis

### pod-root.yaml (no securityContext)

The pod has no `securityContext` at all. The nginx image defaults to root (UID 0). The `restricted` level requires all of:
- `runAsNonRoot: true` (or non-zero `runAsUser`)
- `allowPrivilegeEscalation: false`
- `capabilities.drop: ["ALL"]`
- `seccompProfile` set

All four are missing. The rejection error lists each violation explicitly.

### pod-privileged.yaml (privileged: true)

`privileged: true` is blocked by the `baseline` level, which is the least restrictive non-privileged level. This is blocked even in `lab-19-baseline`. Privileged containers have full access to the host kernel — they can mount the host filesystem, load kernel modules, and escape the container namespace.

### pod-missing-caps-drop.yaml

This pod gets most things right — it sets `runAsNonRoot`, `allowPrivilegeEscalation: false`, and `seccompProfile` — but is missing `capabilities.drop: ["ALL"]`. The `restricted` level requires all capabilities to be dropped. The fix is simple: add that one field.

---

## seccompProfile

seccomp (secure computing mode) is a Linux kernel feature that limits the system calls a process can make. Without a seccomp profile, a container can call any syscall the kernel supports — including dangerous ones used in container escape techniques.

`RuntimeDefault` applies the container runtime's built-in default profile (containerd's or CRI-O's default list), which blocks a subset of dangerous syscalls while allowing everything a normal application needs.

The `restricted` PSA level requires a seccompProfile because unrestricted syscall access is a significant kernel attack surface even from a non-root, non-privileged container.

---

## The restricted checklist (CKA reference)

A pod that passes `restricted` must have ALL of the following:

```yaml
spec:
  securityContext:
    runAsNonRoot: true           # or runAsUser: >0
    seccompProfile:
      type: RuntimeDefault       # or Localhost with a profile
  containers:
  - securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true  # NOT required by policy, but best practice
      capabilities:
        drop: ["ALL"]
```

The `restricted` policy does NOT require `readOnlyRootFilesystem` — that is a best practice beyond the policy minimum. If your pod only needs to pass PSA validation, you can skip it, but you should include it for defense in depth.

---

## Common mistakes

**Forgetting fsGroup:** If your app writes to a mounted volume as a non-root user and the volume's files are owned by root, writes will fail. `fsGroup` sets the group ownership of mounted volumes so the non-root user can write.

**Image runs as root and you set runAsNonRoot: true:** If the container image does not declare a `USER` directive and defaults to root, setting `runAsNonRoot: true` will cause a `CreateContainerConfigError`. You must either choose a different image or build one with a non-root user.

**Confusing PSA with NetworkPolicy:** PSA controls what a pod *is* (its security posture). NetworkPolicy controls what a pod *can reach* (its network connectivity). They are complementary but independent.
