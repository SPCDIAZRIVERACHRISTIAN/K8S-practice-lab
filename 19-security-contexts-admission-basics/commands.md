# Commands — 19 Security Contexts & Pod Security Admission

---

## 1. Create the namespaces

```bash
kubectl apply -f manifests/namespace-restricted.yaml
kubectl apply -f manifests/namespace-baseline.yaml
```

```bash
kubectl describe namespace lab-19-security | grep -A 10 Labels
kubectl describe namespace lab-19-baseline | grep -A 10 Labels
```

> What three modes can a PSA label use? What is the difference between `enforce`, `warn`, and `audit`?

---

## 2. Deploy the secure pod

```bash
kubectl apply -f manifests/pod-secure.yaml
```

```bash
kubectl get pod secure-pod -n lab-19-security
kubectl describe pod secure-pod -n lab-19-security
```

> Did it start? What does the securityContext look like in `kubectl describe`?

```bash
kubectl exec -it secure-pod -n lab-19-security -- id
```

> What user and group is the process running as?

```bash
kubectl exec -it secure-pod -n lab-19-security -- touch /test-write 2>&1 || true
```

> What happened when you tried to write to the root filesystem?

```bash
kubectl exec -it secure-pod -n lab-19-security -- touch /tmp/test-write && echo "tmp is writable"
```

> Why is /tmp writable but / is not?

---

## 3. Break it: pod running as root (no securityContext)

```bash
kubectl apply -f broken/pod-root.yaml
```

> Was the pod created? What error message did the admission controller return?
> Which specific PSA requirement did it violate?

```bash
kubectl get pod root-pod -n lab-19-security 2>&1 || true
```

---

## 4. Break it: privileged container

```bash
kubectl apply -f broken/pod-privileged.yaml
```

> Look at the error message carefully. Does `privileged: true` violate `baseline` or only `restricted`?

```bash
# Try it in the baseline namespace too
kubectl apply -f broken/pod-privileged.yaml --dry-run=server \
  -o yaml 2>&1 | head -20 || true
```

Note: you'd need to edit the namespace field to `lab-19-baseline` to test there. The question is conceptual.

---

## 5. Break it: missing capability drop

```bash
kubectl apply -f broken/pod-missing-caps-drop.yaml
```

> What does the error say? Why does `restricted` require all capabilities to be dropped?

---

## 6. Fix it: add the missing capability drop

Edit `broken/pod-missing-caps-drop.yaml` and add to the container securityContext:

```yaml
capabilities:
  drop: ["ALL"]
```

Apply it:

```bash
kubectl apply -f broken/pod-missing-caps-drop.yaml
```

> Does it pass now, or is there still another violation? Fix each one systematically.

---

## 7. Inspect the secure pod's securityContext fields

```bash
kubectl get pod secure-pod -n lab-19-security -o yaml | grep -A 30 securityContext
```

> Count the fields set at pod level vs container level. Which fields apply to all containers vs to one container?

---

## 8. Test the baseline namespace

```bash
kubectl apply -f manifests/pod-minimal-context.yaml
kubectl get pod minimal-context-pod -n lab-19-baseline
```

> Did the pod deploy? Does `baseline` require `runAsNonRoot`?

---

## 9. Understand what each PSA level allows

Run these to see the PSA labels on both namespaces:

```bash
kubectl get namespaces lab-19-security lab-19-baseline \
  --show-labels
```

Without applying anything, predict: which of the broken pods would be allowed in `lab-19-baseline`?

| Pod | lab-19-security (restricted) | lab-19-baseline (baseline) |
|-----|------------------------------|---------------------------|
| pod-root.yaml | ? | ? |
| pod-privileged.yaml | ? | ? |
| pod-missing-caps-drop.yaml | ? | ? |

Fill in your predictions, then verify by checking the Pod Security Standards docs.

---

## 10. Simulate warn-only mode

```bash
kubectl label namespace lab-19-baseline \
  pod-security.kubernetes.io/warn=restricted \
  --overwrite
```

Now apply the minimal context pod again:

```bash
kubectl apply -f manifests/pod-minimal-context.yaml --force
```

> Did the pod get created? Was there a warning in the output? What is the difference between `warn` and `enforce`?

---

## 11. seccompProfile — what it does

```bash
kubectl get pod secure-pod -n lab-19-security -o yaml | grep -A 5 seccomp
```

> What does `RuntimeDefault` mean as a seccomp profile? Why does `restricted` require a seccompProfile?

---

## 12. Inspect container user without exec

```bash
kubectl get pod secure-pod -n lab-19-security -o jsonpath='{.spec.securityContext}'
kubectl get pod secure-pod -n lab-19-security -o jsonpath='{.spec.containers[0].securityContext}'
```

> What is the difference between the pod-level `runAsUser` and the container-level `runAsUser`? Which wins if both are set?
