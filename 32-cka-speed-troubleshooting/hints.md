# Lab 32 — CKA Speed Troubleshooting: Hints

Use these only if you are stuck. Try to diagnose from the symptom alone first.

---

## Task 1 — app-a: ImagePullBackOff

**Hint:** Run `kubectl describe pod` on one of the failing pods and look at the `Events` section. The error message will tell you exactly what is wrong with the image.

---

## Task 2 — app-b-svc: No endpoints

**Hint:** Check the service selector vs the actual pod labels. Compare `kubectl describe svc app-b-svc -n speed-32` (look at `Selector`) with `kubectl get pods -n speed-32 --show-labels`.

---

## Task 3 — app-c: CreateContainerConfigError

**Hint:** Run `kubectl describe pod app-c -n speed-32` and read the `Events` section carefully. The error references a specific key. Compare it to what actually exists in the ConfigMap.

---

## Task 4 — app-d: Pending

**Hint:** Run `kubectl describe pod app-d -n speed-32` and look at the `Events` section. Then check `kubectl describe nodes` to compare node capacity vs what is being requested.

---

## Task 5 — app-e: Restarting

**Hint:** Run `kubectl describe pod` on the `app-e` pod and look at the `Liveness probe` field. Then check what port nginx actually listens on inside the container.
