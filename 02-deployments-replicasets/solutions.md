# Solutions — 02 Deployments and ReplicaSets

---

## The Deployment → ReplicaSet → Pod chain

```
Deployment
  └── watches: ReplicaSet (creates and owns it)
        └── watches: Pods (creates pods matching its selector)
```

A Deployment does not manage pods directly. It manages a ReplicaSet. The ReplicaSet is what watches pod count and reconciles toward `spec.replicas`.

When you scale a Deployment, it updates the ReplicaSet's desired count. The ReplicaSet then creates or deletes pods.

When you roll out a new image, the Deployment creates a NEW ReplicaSet for the new version and gradually scales it up while scaling down the old one. This is why rollbacks are possible — the old ReplicaSet still exists with `0` replicas.

---

## How the ReplicaSet owns pods

The ReplicaSet uses `spec.selector.matchLabels` to find its pods. It counts all pods in the namespace that match that selector. If the count is below `spec.replicas`, it creates new pods. If above, it deletes pods.

Pod ownership is tracked with `ownerReferences` in the pod's metadata. Run this to see it:

```bash
kubectl get pod <pod-name> -n lab-02-deployments -o yaml | grep -A5 ownerReferences
```

---

## Expected error from broken selector

```
The Deployment "nginx-broken-selector" is invalid:
spec.template.metadata.labels: Invalid value: map[string]string{"app":"nginx-web"}:
`selector` does not match template `labels`
```

Kubernetes validates this at admission time. The API server rejects the object before it is stored in etcd. No ReplicaSet or pods are created.

This validation exists because if the selector did not match the template labels, the ReplicaSet would create pods that it would never count as its own, leading to infinite pod creation.

---

## Scaling behavior

When scaling down, the ReplicaSet picks pods to delete based on scheduling considerations (newest pods are typically deleted first). The selection is deterministic but not always obvious from the pod names alone.

The ReplicaSet name does NOT change when you scale. The ReplicaSet object is reused with a different desired count.

---

## Common mistakes

**Editing a Deployment's selector after creation**
Deployment selectors are immutable. You cannot change `spec.selector` on an existing Deployment. You must delete and recreate the Deployment.

**Confusing ReplicaSet with Deployment**
You can create a ReplicaSet directly without a Deployment, but you lose rolling updates and rollback history. Always use a Deployment for stateless workloads.

**kubectl scale vs editing the manifest**
`kubectl scale` changes the live cluster state but does not update the YAML file. If you later `kubectl apply` the original manifest, the replica count reverts to what is in the file. Keep your manifests and cluster state in sync.
