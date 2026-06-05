# Solutions — 04 ConfigMaps, Secrets, and Environment Variables

---

## ConfigMap vs Secret

| | ConfigMap | Secret |
|--|-----------|--------|
| Purpose | Non-sensitive configuration | Sensitive data (credentials, tokens, keys) |
| Storage | Plain text in etcd | base64-encoded in etcd |
| Encryption | No (unless etcd encryption at rest is configured) | No by default |
| Visibility | Readable by anyone with `get configmap` | Requires `get secret` RBAC permission |

**base64 is not encryption.** It is encoding. Anyone who can read the Secret object can decode the value in seconds. The value of Secrets is that:
- They are a separate object type, so RBAC can restrict access more granularly
- They are not printed in most `describe` outputs by default
- Secret management tooling (Vault, Sealed Secrets, external-secrets-operator) integrates via the Secret API

---

## Expected: kubectl describe secret app-secrets

```
Name:         app-secrets
Namespace:    lab-04-config
Type:         Opaque

Data
====
DB_PASS:  15 bytes
DB_USER:  7 bytes
```

The values are hidden. To read them you must use `-o yaml` or `-o jsonpath` and decode manually.

---

## Expected pod status for broken pods

**pod-missing-key:**
```
Status: Pending
Reason: CreateContainerConfigError
Message: couldn't find key DOES_NOT_EXIST in ConfigMap lab-04-config/app-config
```

**pod-missing-secret:**
```
Status: Pending
Reason: CreateContainerConfigError
Message: secret "nonexistent-secret" not found
```

The key difference:
- Missing key: the ConfigMap exists but the key is absent
- Missing secret: the entire Secret object does not exist

Both result in the pod never starting. The container is not even created. The pod stays in `Pending` with `CreateContainerConfigError`.

---

## How Kubernetes resolves env var references

When a pod is scheduled on a node, the kubelet tries to resolve all `valueFrom` references before starting the container. If any reference cannot be resolved, the container start is blocked and the event `CreateContainerConfigError` is recorded.

The pod does not retry the failed env var lookup on its own. It will stay in this state until you fix the reference and recreate the pod.

---

## Common mistakes

**Using `data` with raw values in a Secret**
If you use `data:` in a Secret manifest, the values must be base64-encoded. If you use `stringData:`, Kubernetes encodes them for you. Using `data` with plain text silently stores the wrong value.

**Assuming Secrets are encrypted**
By default, etcd does not encrypt Secrets at rest. Any user with etcd access can read them directly. Real secret management requires enabling EncryptionConfiguration or using an external secrets provider.

**Forgetting that ConfigMap/Secret changes don't auto-update running pods**
If you change a ConfigMap after the pod has started, the pod's environment variables do not update. You must delete and recreate the pod. Volume-mounted ConfigMaps do eventually update, but with a delay.
