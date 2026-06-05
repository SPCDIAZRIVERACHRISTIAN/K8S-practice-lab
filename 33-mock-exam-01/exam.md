# Mock Exam 01

**Time limit:** 2 hours  
**Total points:** 65  
**Allowed resources:** kubernetes.io documentation

Start your timer now.

---

## Task 1 [2 points]

**Context:** You will use namespace `exam-01` for most tasks in this exam.

**Task:** Create namespace `exam-01`.

---

## Task 2 [3 points]

**Context:** Namespace `exam-01`.

**Task:** Create a pod named `web-pod` using image `nginx:stable`. Set the label `tier=frontend` on the pod. Ensure the pod uses the `default` ServiceAccount.

---

## Task 3 [5 points]

**Context:** Namespace `exam-01`.

**Task:** Create a deployment named `web-deploy` with 3 replicas using image `nginx:stable`. The pod template must have label `app=web`. Set resource requests on the container: CPU `100m`, memory `128Mi`.

---

## Task 4 [3 points]

**Context:** Namespace `exam-01`. Deployment `web-deploy` exists from Task 3.

**Task:** Scale `web-deploy` to 5 replicas. Update the container image to `nginx:1.25`. Confirm the rollout completes successfully.

---

## Task 5 [4 points]

**Context:** Namespace `exam-01`. Deployment `web-deploy` exists.

**Task:** Expose `web-deploy` as a NodePort service named `web-svc` in namespace `exam-01`. The service must listen on port 80 and use node port `30090`.

---

## Task 6 [4 points]

**Context:** Namespace `exam-01`.

**Task:** Create a ConfigMap named `app-settings` in `exam-01` with the following data: `log_level=INFO` and `max_connections=100`. Create a pod named `configured-pod` using image `busybox:stable` with command `sleep 3600`. Inject all keys from `app-settings` as environment variables using `envFrom`.

---

## Task 7 [4 points]

**Context:** Namespace `exam-01`.

**Task:** Create a Secret named `db-secret` in `exam-01` with the following data: `DB_HOST=db.internal` and `DB_PASS=p@ssw0rd`. Create a pod named `secret-pod` using image `nginx:stable` that mounts `db-secret` as a volume at `/etc/db-config`.

---

## Task 8 [4 points]

**Context:** Namespace `exam-01`.

**Task:** Create a ServiceAccount named `app-sa` in `exam-01`. Create a Role named `app-role` in `exam-01` that allows `get`, `list`, and `watch` on `pods` and `configmaps`. Create a RoleBinding named `app-sa-binding` in `exam-01` that binds `app-sa` to `app-role`.

---

## Task 9 [3 points]

**Context:** Namespace `exam-01`. ServiceAccount `app-sa` exists from Task 8.

**Task:** Using `kubectl auth can-i`, verify that `app-sa` can list pods in `exam-01`. Also verify that `app-sa` cannot delete pods in `exam-01`.

---

## Task 10 [4 points]

**Context:** Namespace `exam-01`.

**Task:** Create a PersistentVolumeClaim named `app-storage` in `exam-01` with storage class `standard`, size `1Gi`, access mode `ReadWriteOnce`. Create a pod named `storage-pod` using image `nginx:stable` that mounts `app-storage` at `/data`. Verify the PVC is `Bound` and the pod is `Running`.

---

## Task 11 [3 points]

**Context:** Namespace `exam-01`.

**Task:** Create a CronJob named `cleanup-job` in `exam-01` using image `busybox:stable`, schedule `*/5 * * * *`, with the command `echo "cleanup complete"`.

---

## Task 12 [5 points]

**Context:** Namespace `exam-01`.

**Task:** Create a NetworkPolicy named `deny-all` in `exam-01` that denies all ingress to all pods in the namespace. Then create a NetworkPolicy named `allow-web` in `exam-01` that permits ingress on port 80 to pods with label `app=web` from pods with label `tier=frontend`.

---

## Task 13 [4 points]

**Context:** Namespace `exam-01`. Cluster nodes: `kind-control-plane`, `kind-worker`, `kind-worker2`.

**Task:** Add a taint `env=test:NoSchedule` to node `kind-worker`. Create a pod named `tolerant-pod` in `exam-01` using image `nginx:stable` with a toleration that allows scheduling on `kind-worker` with this taint. Verify the pod is scheduled on `kind-worker`. Then remove the taint from `kind-worker`.

---

## Task 14 [3 points]

**Context:** Cluster nodes: `kind-control-plane`, `kind-worker`, `kind-worker2`.

**Task:** Cordon node `kind-worker2` so that no new pods are scheduled on it. Create a pod in namespace `exam-01` and verify it is scheduled on `kind-worker` (not `kind-worker2` and not the control-plane). Then uncordon `kind-worker2`.

---

## Task 15 [5 points]

**Context:** You must create both the namespace and the deployment for this task.

**Task:** Create namespace `exam-01-broken`. Create a deployment named `broken-deploy` in `exam-01-broken` with 2 replicas using image `nginx:broken-tag`. The deployment will fail to start. Fix the deployment so both pods are Running using image `nginx:stable`.

---

## Task 16 [4 points]

**Context:** Namespace `exam-01`.

**Task:** Create a StatefulSet named `stateful-app` in `exam-01` with 2 replicas using image `nginx:stable`. Create a headless Service named `stateful-svc` for it in `exam-01`. Each pod in the StatefulSet must have a volumeClaimTemplate named `data` requesting `100Mi` with storage class `standard`.

---

## Task 17 [5 points]

**Context:** etcd is running on the control-plane node.

**Task:** Take a snapshot of etcd and save it to `/tmp/etcd-exam-backup.db`. Verify the snapshot is valid using `etcdctl snapshot status`.

---

**Stop your timer. Record your elapsed time in `notes.md`.**

Self-score using `solutions.md`. Then fill in the rest of `notes.md`.
