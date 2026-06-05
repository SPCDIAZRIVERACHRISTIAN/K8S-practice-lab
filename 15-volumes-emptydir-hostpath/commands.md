# 15 — Commands

Run in order. Read the output at each step.

---

## 1. Create the namespace and apply both pods

```bash
kubectl create namespace lab-15-volumes
kubectl apply -f manifests/pod-emptydir.yaml
kubectl apply -f manifests/pod-hostpath.yaml
kubectl get pods -n lab-15-volumes -o wide
```

> Note which node each pod landed on.

---

## 2. Confirm the emptyDir file was written

```bash
kubectl logs emptydir-pod -n lab-15-volumes
kubectl exec emptydir-pod -n lab-15-volumes -- cat /data/test.txt
```

> What does the file contain?

---

## 3. Write more data to the emptyDir volume

```bash
kubectl exec emptydir-pod -n lab-15-volumes -- sh -c "echo 'second line' >> /data/test.txt && cat /data/test.txt"
```

---

## 4. Delete the emptyDir pod

```bash
kubectl delete pod emptydir-pod -n lab-15-volumes
kubectl apply -f manifests/pod-emptydir.yaml
kubectl exec emptydir-pod -n lab-15-volumes -- cat /data/test.txt
```

> Is the file there? What happened to the data you wrote?

---

## 5. Inspect the emptyDir volume inside the pod

```bash
kubectl exec emptydir-pod -n lab-15-volumes -- df -h /data
kubectl exec emptydir-pod -n lab-15-volumes -- ls -la /data
```

> Where is the emptyDir backed on disk? What filesystem type does `df` show?

---

## 6. Confirm the hostPath file was written

```bash
kubectl logs hostpath-pod -n lab-15-volumes
kubectl exec hostpath-pod -n lab-15-volumes -- cat /data/test.txt
```

---

## 7. Write more data to the hostPath volume

```bash
kubectl exec hostpath-pod -n lab-15-volumes -- sh -c "echo 'second line' >> /data/test.txt && cat /data/test.txt"
```

---

## 8. Delete the hostPath pod and recreate it

```bash
kubectl delete pod hostpath-pod -n lab-15-volumes
kubectl apply -f manifests/pod-hostpath.yaml
```

Wait for the pod to start:

```bash
kubectl get pod hostpath-pod -n lab-15-volumes
kubectl exec hostpath-pod -n lab-15-volumes -- cat /data/test.txt
```

> Is the file still there this time? Why is the result different from emptyDir?

---

## 9. Verify the data lives on the node, not in the pod

```bash
kubectl get pod hostpath-pod -n lab-15-volumes -o wide
```

Note the node name. Now look at the file directly on the kind node:

```bash
# Find the kind worker container name that matches the node
docker ps

# Exec into the kind node container and check the file
docker exec <kind-worker-container-name> cat /tmp/lab-15-hostpath/test.txt
```

> You can see the file directly on the node's filesystem. The pod was just mounting a path that already existed on the node.

---

## 10. Demonstrate the node-binding problem

The hostPath pod is pinned to whichever node it first landed on (because the data is there). To simulate what happens on a different node, add the file to a second node and see they are independent:

```bash
# Exec into the OTHER worker and look for the file
docker exec <other-kind-worker> ls /tmp/lab-15-hostpath 2>/dev/null || echo "Path does not exist on this node"
```

> The path may not even exist on the other node. If the pod rescheduled there, it would start with an empty /data directory.

---

## 11. Demonstrate emptyDir shared between two containers

Apply this inline to see how two containers in one pod can share scratch space via emptyDir:

```bash
kubectl run shared-emptydir --namespace=lab-15-volumes --image=busybox:1.36 --dry-run=client -o yaml > /tmp/shared.yaml
```

Actually, run this instead — apply a quick two-container pod with a shared emptyDir:

```bash
kubectl apply -n lab-15-volumes -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume
  namespace: lab-15-volumes
spec:
  containers:
  - name: producer
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date >> /shared/log.txt; sleep 2; done"]
    volumeMounts:
    - name: shared
      mountPath: /shared
  - name: consumer
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: shared
      mountPath: /shared
  volumes:
  - name: shared
    emptyDir: {}
EOF
```

```bash
# Wait a few seconds, then read the shared log from the consumer container
kubectl exec shared-volume -c consumer -n lab-15-volumes -- cat /shared/log.txt
```

> Both containers read and write the same directory. This is the primary use case for emptyDir.

---

## 12. Clean up

```bash
./cleanup.sh
```
