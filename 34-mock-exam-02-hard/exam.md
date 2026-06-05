# Mock Exam 02 — Hard

**Time limit:** 2 hours  
**Total points:** 62  
**Allowed resources:** kubernetes.io documentation

Start your timer now.

---

## Task 1 [3 points]

**Context:** Cluster is running with nodes `kind-control-plane`, `kind-worker`, `kind-worker2`.

**Task:** Create namespace `exam-02`. List all pods in `kube-system` that are static pods. Static pods are identifiable by their naming convention (their name ends with the node name). Output just the pod names to a file at `/tmp/static-pods.txt`.

---

## Task 2 [5 points]

**Context:** Namespace `exam-02`.

**Task:** Create a pod named `mystery-pod` in `exam-02` using image `busybox:stable` with command `["sh", "-c", "cat /etc/config/settings.json"]`. The pod will enter `CrashLoopBackOff`. Diagnose the failure. Fix it by creating a ConfigMap named `pod-config` in `exam-02` with a data key `settings.json` whose value is `{}`. Mount the ConfigMap as a volume at `/etc/config` in the pod. The fixed pod should stay Running (change the command to `sleep 3600`).

---

## Task 3 [4 points]

**Context:** Namespace `exam-02`.

**Task:** Create a deployment named `api-server` in `exam-02` using image `nginx:stable` with 3 replicas. Add a liveness probe: `httpGet`, path `/health`, port `8080`, `initialDelaySeconds: 5`, `periodSeconds: 10`. The pods will be killed due to the failing probe. Fix the deployment so all 3 pods are Running and stable by correcting the probe port to `80`.

---

## Task 4 [5 points]

**Context:** Namespace `exam-02`. Cluster nodes: `kind-control-plane`, `kind-worker`, `kind-worker2`.

**Task:** Create a deployment named `frontend` in `exam-02` using image `nginx:stable` with 3 replicas. Create a PodDisruptionBudget named `frontend-pdb` in `exam-02` ensuring at least 2 pods are always available. Cordon `kind-worker2`. Drain `kind-worker` (use `--ignore-daemonsets --delete-emptydir-data`; pods should reschedule on `kind-worker2`). Verify all 3 pods end up Running. Uncordon both `kind-worker` and `kind-worker2`.

---

## Task 5 [4 points]

**Context:** Namespace `exam-02`. Cluster has nodes.

**Task:** Create a ServiceAccount named `reader-sa` in `exam-02`. Create a ClusterRole named `cluster-reader` that allows `get`, `list`, `watch` on `nodes`, `persistentvolumes`, and `storageclasses`. Create a ClusterRoleBinding named `cluster-reader-binding` granting `reader-sa` this ClusterRole. Verify with `kubectl auth can-i list nodes --as=system:serviceaccount:exam-02:reader-sa`.

---

## Task 6 [3 points]

**Context:** Namespace `exam-02`.

**Task:** Create a PVC named `stuck-pvc` in `exam-02` with `storageClassName: fast-storage`, `1Gi`, `ReadWriteOnce`. The PVC will be in `Pending` state. Diagnose why and fix it by updating the PVC to use `storageClassName: standard`. Verify the PVC becomes `Bound`.

---

## Task 7 [5 points]

**Context:** Namespace `exam-02`.

**Task:** Create a StatefulSet named `cache` in `exam-02` with 3 replicas using image `nginx:stable`. Create a headless Service named `cache-headless` for it in `exam-02`. Each pod must have a volumeClaimTemplate named `cache-data` requesting `50Mi` with storage class `standard`. After the pods are Running, verify that the per-pod DNS name `cache-0.cache-headless.exam-02.svc.cluster.local` resolves from within the cluster.

---

## Task 8 [4 points]

**Context:** Namespace `exam-02`. Node `kind-worker`.

**Task:** Add the label `zone=east` to node `kind-worker`. Create a deployment named `zonal-app` in `exam-02` using image `nginx:stable` with 2 replicas. Configure node affinity (`requiredDuringSchedulingIgnoredDuringExecution`) so that pods only schedule on nodes with label `zone=east`. Verify both pods are Running on `kind-worker`. Remove the label `zone=east` from `kind-worker` when done.

---

## Task 9 [3 points]

**Context:** etcd is running on the control-plane.

**Task:** Take a snapshot of etcd and save it to `/tmp/etcd-hard-backup.db`. Using `etcdctl snapshot status`, report the following three values in a file at `/tmp/etcd-status.txt`: revision number, total keys count, and database size.

---

## Task 10 [4 points]

**Context:** kind cluster — control plane is a Docker container named `kind-control-plane`.

**Task:** Exec into the `kind-control-plane` container and run `kubeadm certs check-expiration`. Identify the certificate that expires soonest. Write the certificate name and its expiry date to `/tmp/cert-expiry.txt`.

---

## Task 11 [5 points]

**Context:** You must create the namespace for this task.

**Task:** Create namespace `exam-02-net`. Create a complete NetworkPolicy set:
1. A policy named `default-deny` that denies all ingress to all pods in `exam-02-net`.
2. A policy named `allow-web` that permits ingress on port 80 to pods with label `role=web` from pods with label `role=client`.
3. A policy named `allow-db` that permits ingress on port 3306 to pods with label `role=db` from pods with label `role=web` only.

Create three pods in `exam-02-net`: one named `client-pod` (label `role=client`), one named `web-pod` (label `role=web`), one named `db-pod` (label `role=db`). Use image `busybox:stable` for all three, command `sleep 3600`.

---

## Task 12 [4 points]

**Context:** Namespace `exam-02`.

**Task:** Create a CronJob named `report-gen` in `exam-02` using image `busybox:stable`, schedule `0 6 * * *`, with command `sh -c 'echo "report generated at $(date)"'`. After creating the CronJob, manually trigger a Job from it using `kubectl create job`. Verify the manually triggered Job completes.

---

## Task 13 [3 points]

**Context:** Namespace `exam-02`.

**Task:** Create a deployment named `heavy-app` in `exam-02` using image `nginx:stable` with 1 replica and resource requests of `cpu: "200"` and `memory: "1000Gi"`. The pod will be `Pending`. Diagnose the root cause. Fix the deployment by setting resource requests to `cpu: "200m"` and `memory: "256Mi"`. Verify the pod is Running.

---

## Task 14 [5 points]

**Context:** You will create a Kustomize directory structure.

**Task:** Create a Kustomize setup at `/tmp/kustomize-exam/`:
- **base:** a Deployment named `kustomized-app` using image `nginx:stable` with 1 replica, in namespace `exam-02`.
- **dev overlay:** sets replicas to 1 and image to `nginx:1.25`.
- **prod overlay:** sets replicas to 3 and image to `nginx:stable`.

Apply the prod overlay to the cluster. The deployment must have 3 replicas running in namespace `exam-02`.

---

## Task 15 [5 points]

**Context:** Namespace `exam-02-net` (created in Task 11).

**Task:** Create a deployment named `mystery-app` in `exam-02-net` using image `nginx:stable` with 2 replicas. Pods must have label `app=mystery`. Create a Service named `mystery-svc` in `exam-02-net` with selector `app: mysterio` (intentional typo). The service will have no endpoints. Diagnose the problem. Fix the service selector so that endpoints appear. Verify endpoints are populated.

---

**Stop your timer. Record your elapsed time in `notes.md`.**

Self-score using `solutions.md`. Then fill in the rest of `notes.md`.
