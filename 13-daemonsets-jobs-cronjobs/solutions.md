# Solutions — 13 DaemonSets, Jobs, and CronJobs

---

## DaemonSet

A DaemonSet ensures exactly one pod runs on each eligible node. When a new node joins the cluster, the DaemonSet controller automatically creates a pod on it. When a node is removed, the pod is garbage collected.

The DaemonSet in this lab includes a toleration for the control-plane taint:
```yaml
tolerations:
- key: node-role.kubernetes.io/control-plane
  effect: NoSchedule
```

Without this toleration, the DaemonSet would skip the control-plane node. With it, the pod runs on every node including the control-plane.

**Real-world DaemonSet use cases:**
- Node-level log collectors (Fluentd, Filebeat)
- Node-level metrics agents (Prometheus node exporter)
- Network plugins (kube-proxy is a DaemonSet)
- Storage drivers
- Security agents

---

## Job

A Job runs a task to completion and tracks success. Unlike a Deployment, it does not try to keep a process running — it tries to get N successful completions.

`completions: 3` — the Job must succeed 3 times total
`parallelism: 2` — run up to 2 pods at the same time
`backoffLimit: 2` — retry up to 2 times before marking the Job as failed

Job pods are NOT deleted when the Job completes. They stay in `Completed` or `Failed` state so you can retrieve their logs. Kubernetes does not auto-delete them unless a `ttlSecondsAfterFinished` is set.

`restartPolicy: Never` on the pod template means: if the container exits (for any reason), do NOT restart the container. The Job controller handles retrying by creating new pods.

---

## Broken Job lifecycle

With `backoffLimit: 2`:

1. Pod 1 created → container exits 1 → pod stays in Failed
2. Pod 2 created → container exits 1 → pod stays in Failed
3. Pod 3 created → container exits 1 → pod stays in Failed
4. backoffLimit exhausted → Job condition: `Failed`, reason: `BackoffLimitExceeded`

Total pods created: 3 (initial + 2 retries = backoffLimit + 1).

To fix: change the command so the container exits 0. Since Jobs are immutable, you must delete the Job and recreate it.

---

## CronJob

A CronJob creates a new Job on a cron schedule. It is a Job factory.

`schedule: "* * * * *"` — every minute (min hour day-of-month month day-of-week)

`concurrencyPolicy: Forbid` — if the previous Job is still running when the next scheduled run comes, skip the new run. Prevents overlap.

`successfulJobsHistoryLimit: 3` — keep the last 3 successful Job objects. Older ones are garbage collected.

Suspend/resume: `spec.suspend: true` pauses Job creation without deleting the CronJob. `spec.suspend: false` resumes it.

---

## Common mistakes

**Not setting `restartPolicy: Never` on Job pod templates**
Jobs require `restartPolicy: Never` or `restartPolicy: OnFailure`. The default `Always` is rejected. If you use `OnFailure`, the container is restarted in the same pod (not a new pod) on failure — this means logs accumulate from multiple runs in one pod.

**Expecting Job pods to be deleted after completion**
They are not. If you have many Jobs running frequently, old pods accumulate. Set `ttlSecondsAfterFinished` on the Job spec to auto-delete completed pods after a delay.

**CronJob schedule timezone**
The CronJob schedule runs in the timezone of the kube-controller-manager. By default this is UTC. If your cluster's controllers run in UTC, `"0 9 * * *"` means 9am UTC, not 9am local time.
