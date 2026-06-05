# 13 — Commands

Run in order. Read the output at each step.

---

## 1. Create the namespace

```bash
kubectl create namespace lab-13-workloads
```

---

## 2. Apply the DaemonSet

```bash
kubectl apply -f manifests/daemonset.yaml
kubectl get daemonset -n lab-13-workloads
kubectl get pods -n lab-13-workloads -o wide
```

> How many pods were created? Does it match the number of nodes in the cluster? Which nodes have a pod?

---

## 3. Read DaemonSet logs

```bash
kubectl logs -n lab-13-workloads -l app=log-collector
```

> What does each pod print? Which hostname does each one report?

---

## 4. Describe the DaemonSet

```bash
kubectl describe daemonset log-collector -n lab-13-workloads
```

> Look at: `Desired Number of Nodes Scheduled`, `Current Number of Nodes Scheduled`, `Node-Selector`, `Tolerations`. What toleration allows it to run on the control-plane node?

---

## 5. Apply the working Job

```bash
kubectl apply -f manifests/job-working.yaml
kubectl get job compute-job -n lab-13-workloads -w
```

> Press Ctrl+C when the COMPLETIONS column shows `3/3`. How long did it take?

---

## 6. Inspect the Job

```bash
kubectl describe job compute-job -n lab-13-workloads
```

> Look at: `Completions`, `Parallelism`, `Start Time`, `Duration`, `Pods Statuses`.

---

## 7. Read Job pod logs

```bash
kubectl get pods -n lab-13-workloads -l job-name=compute-job
kubectl logs -n lab-13-workloads -l job-name=compute-job
```

> What did each pod print? Notice how pods are labeled with `job-name`.

---

## 8. What happens to completed Job pods

```bash
kubectl get pods -n lab-13-workloads
```

> After a Job completes, its pods remain in `Completed` status. They are not deleted automatically. Why might this be useful?

---

## 9. Apply the broken Job

```bash
kubectl apply -f broken/job-broken-command.yaml
kubectl get job broken-job -n lab-13-workloads -w
```

> Watch the Completions and the pod count. What happens when the command exits with code 1?

---

## 10. Inspect the failed Job

```bash
kubectl describe job broken-job -n lab-13-workloads
kubectl get pods -n lab-13-workloads -l job-name=broken-job
kubectl logs -n lab-13-workloads -l job-name=broken-job
```

> What status does the Job reach? How many pods were created in total? What does `backoffLimit: 2` mean?

---

## 11. Fix and rerun the broken Job

Edit `broken/job-broken-command.yaml` — change `exit 1` to `exit 0`.

Jobs are immutable once created. Delete and recreate:

```bash
kubectl delete job broken-job -n lab-13-workloads
kubectl apply -f broken/job-broken-command.yaml
kubectl get job broken-job -n lab-13-workloads -w
```

> Does it complete now?

---

## 12. Apply and observe the CronJob

```bash
kubectl apply -f manifests/cronjob.yaml
kubectl get cronjob -n lab-13-workloads
```

Wait up to 2 minutes, then:

```bash
kubectl get jobs -n lab-13-workloads
kubectl get pods -n lab-13-workloads
```

> Did a Job appear? Did the pod from that Job complete?

---

## 13. Watch the CronJob create multiple Jobs

```bash
kubectl get jobs -n lab-13-workloads -w
```

> Wait for a second Job to appear. How many Jobs are kept in history?

---

## 14. Suspend the CronJob

```bash
kubectl patch cronjob report-cron -n lab-13-workloads -p '{"spec":{"suspend":true}}'
kubectl get cronjob report-cron -n lab-13-workloads
```

> Is the SUSPEND column now `True`? Wait 2 minutes and verify no new Jobs are created.

---

## 15. Resume the CronJob

```bash
kubectl patch cronjob report-cron -n lab-13-workloads -p '{"spec":{"suspend":false}}'
kubectl get cronjob report-cron -n lab-13-workloads
```

---

## 16. Clean up

```bash
./cleanup.sh
```
