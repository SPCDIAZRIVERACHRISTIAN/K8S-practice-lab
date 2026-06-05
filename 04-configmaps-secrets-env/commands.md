# 04 — Commands

Run in order. Read the output at each step.

---

## 1. Create the namespace

```bash
kubectl create namespace lab-04-config
```

---

## 2. Apply the ConfigMap and Secret

```bash
kubectl apply -f manifests/configmap.yaml
kubectl apply -f manifests/secret.yaml
```

```bash
kubectl get configmap app-config -n lab-04-config
kubectl get secret app-secrets -n lab-04-config
```

> Inspect both objects. What do you see in the ConfigMap data vs the Secret data?

---

## 3. Inspect the ConfigMap contents

```bash
kubectl describe configmap app-config -n lab-04-config
```

> Can you read the values? They are stored as plain text.

---

## 4. Inspect the Secret contents

```bash
kubectl describe secret app-secrets -n lab-04-config
```

```bash
kubectl get secret app-secrets -n lab-04-config -o yaml
```

> What does the Secret look like in the `describe` output vs the raw YAML? Where is the data stored?

---

## 5. Decode a secret value

```bash
kubectl get secret app-secrets -n lab-04-config -o jsonpath='{.data.DB_PASS}' | base64 --decode
```

> What does this tell you about how Secrets protect data?

---

## 6. Apply the working pod

```bash
kubectl apply -f manifests/pod.yaml
kubectl get pod app-pod -n lab-04-config
```

---

## 7. Read the pod logs to see env vars printed

```bash
kubectl logs app-pod -n lab-04-config
```

> Can you see the values from the ConfigMap and Secret in the logs?

---

## 8. Exec into the pod and inspect env vars

```bash
kubectl exec -it app-pod -n lab-04-config -- env
```

> Find `APP_ENV`, `DB_USER`, and `DB_PASS` in the output.

---

## 9. Apply the broken pod — missing ConfigMap key

```bash
kubectl apply -f broken/pod-missing-key.yaml
kubectl get pod pod-missing-key -n lab-04-config
kubectl describe pod pod-missing-key -n lab-04-config
```

> What is the pod status? What does the Events section say?

---

## 10. Apply the broken pod — missing Secret

```bash
kubectl apply -f broken/pod-missing-secret.yaml
kubectl get pod pod-missing-secret -n lab-04-config
kubectl describe pod pod-missing-secret -n lab-04-config
```

> What is the pod status? Is the error message different from the missing key error?

---

## 11. Fix one of the broken pods

Edit `broken/pod-missing-key.yaml`: change `DOES_NOT_EXIST` to `LOG_LEVEL`.

Then delete and reapply:

```bash
kubectl delete pod pod-missing-key -n lab-04-config
kubectl apply -f broken/pod-missing-key.yaml
kubectl get pod pod-missing-key -n lab-04-config
```

> Did the pod start successfully after the fix?

---

## 12. Clean up

```bash
./cleanup.sh
```
