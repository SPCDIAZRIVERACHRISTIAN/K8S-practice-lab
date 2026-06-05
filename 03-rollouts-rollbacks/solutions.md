# Solutions — 03 Rollouts and Rollbacks

---

## How a rolling update works

When you update a Deployment's image, Kubernetes does not replace all pods at once. It:

1. Creates a new ReplicaSet with the new pod template
2. Scales up the new ReplicaSet one pod at a time (controlled by `maxSurge`)
3. Scales down the old ReplicaSet one pod at a time (controlled by `maxUnavailable`)
4. Continues until the new ReplicaSet has all replicas and the old has zero

The old ReplicaSet is kept at 0 replicas (not deleted) so that rollback is instant — no new pods need to be created, just the counts are reversed.

---

## maxSurge and maxUnavailable

In the manifest for this lab:

```yaml
rollingUpdate:
  maxSurge: 1
  maxUnavailable: 1
```

- `maxSurge: 1` — at most 1 extra pod above the desired count can exist during the update
- `maxUnavailable: 1` — at most 1 pod below the desired count can be unavailable during the update

With 3 replicas, maxSurge=1, maxUnavailable=1:
- Maximum pods during update: 4 (3 + 1)
- Minimum available pods during update: 2 (3 - 1)

---

## What happens during a broken rollout

When you push `nginx:badversion`:

1. Kubernetes creates new pods using the bad image
2. Those pods enter `ErrImagePull` → `ImagePullBackOff`
3. Kubernetes waits — it will NOT replace more old pods than `maxUnavailable` allows
4. The rollout stalls: new pods cannot become Ready, old pods are kept running

This is the safety mechanism. Your service stays up because old pods are not removed until new pods are healthy.

---

## Rollback mechanics

`kubectl rollout undo` simply reverses the scaling:

1. Identifies the previous ReplicaSet
2. Scales it back up to the desired count
3. Scales the current (broken) ReplicaSet down to 0

No new pods are built from scratch — the previous ReplicaSet still has its pod template cached. This makes rollbacks fast.

After a rollback, a new revision entry is added to rollout history. The total revision count increases.

---

## Expected rollout history after the lab

```
REVISION  CHANGE-CAUSE
1         <none>          ← nginx:1.25
2         <none>          ← nginx:1.26
3         <none>          ← nginx:badversion (stalled)
4         <none>          ← rollback to nginx:1.26
5         <none>          ← rollback to nginx:1.25 (if you ran --to-revision=1)
```

---

## Common mistakes

**`kubectl set image` does not update your YAML file**
The live cluster state changes, but `manifests/deployment.yaml` still has `nginx:1.25`. After multiple `set image` commands, your YAML and cluster are out of sync. In real workflows, update the YAML and `kubectl apply` it.

**Expecting rollback to go back to revision 1 with `rollout undo`**
`rollout undo` without `--to-revision` goes back exactly one step. Use `--to-revision=N` to jump to a specific revision.

**Not watching `rollout status` during updates**
`kubectl apply` or `kubectl set image` returns immediately. The rollout continues in the background. Always follow up with `rollout status` to confirm the update completed.
