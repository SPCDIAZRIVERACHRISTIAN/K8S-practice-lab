# Solutions — 01 Pods

Read this after completing `notes.md`.

---

## Pod lifecycle

A pod moves through these phases:

| Phase | Meaning |
|-------|---------|
| `Pending` | Pod accepted by the cluster, waiting for a node assignment or image pull |
| `ContainerCreating` | Node is pulling the image and setting up the container |
| `Running` | At least one container is running |
| `Succeeded` | All containers exited with code 0 (for batch jobs) |
| `Failed` | At least one container exited with a non-zero code |
| `CrashLoopBackOff` | Container keeps crashing, kubelet is backing off restarts |

---

## Expected: kubectl get pods -n lab-01-pods

```
NAME         READY   STATUS    RESTARTS   AGE
nginx-pod    1/1     Running   0          30s
```

`1/1` means 1 container is ready out of 1 total containers in the pod.

---

## What kubectl describe pod shows

`kubectl describe pod` shows:
- The node the pod is scheduled on
- The pod IP address
- Container spec (image, ports, resource requests)
- Volume mounts
- Conditions (Initialized, Ready, ContainersReady, PodScheduled)
- The Events log — this is the most useful section for troubleshooting

`kubectl get pod` shows only current state, no history.

---

## What ImagePullBackOff means

When Kubernetes cannot pull an image, the sequence is:

1. `ErrImagePull` — first failure, tries to pull and gets an error
2. `ImagePullBackOff` — kubelet is backing off (waiting longer between retries)

Common causes:
- The image tag does not exist (e.g., `nginx:doesnotexist`)
- The image name is misspelled
- The registry requires authentication and no image pull secret is configured
- The registry is unreachable from the node

---

## Why the deleted pod does not return

A standalone pod has no controller watching it. When you delete it, it is gone. There is nothing to recreate it.

A `Deployment` solves this: it creates a `ReplicaSet` which watches how many pods matching its selector are running and reconciles toward the desired count. Delete a pod owned by a Deployment and the ReplicaSet creates a replacement within seconds.

---

## Exec into a pod

```bash
kubectl exec -it nginx-pod -n lab-01-pods -- /bin/bash
```

- `-it` gives you an interactive terminal
- `--` separates kubectl arguments from the command to run inside the container
- You are inside the container's filesystem and process namespace, not the node

The `hostname` command inside the container returns the pod name, because Kubernetes sets the pod name as the container hostname by default.

---

## Port-forward

`kubectl port-forward` is a debugging tool. It tunnels traffic from your localhost to a pod. It is not how you expose services in a real environment — that is what `Services` and `Ingress` are for (covered in labs 06 and 08).

---

## Common mistakes

**Forgetting `-n lab-01-pods`**
Most commands default to the `default` namespace. If you do not specify `-n`, you will not see resources in your lab namespace.

**Re-applying a broken pod manifest without deleting first**
If a pod exists with a bad image, re-applying the fixed manifest does NOT update the running pod's image automatically. You must delete the pod and re-apply, or use `kubectl edit pod` to patch it in place.

**Expecting a deleted pod to come back**
Pods without controllers are fire-and-forget. They stay deleted. Lab 02 covers Deployments, which add the controller that provides self-healing.
