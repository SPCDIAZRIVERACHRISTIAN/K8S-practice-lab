# Commands — 24 Upgrades & Node Maintenance

---

## 1. Set up the lab

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/daemonset.yaml
```

Wait for pods to be Running:

```bash
kubectl get pods -n lab-24-maintenance -o wide
```

> Which nodes are the webapp pods running on? Is the distribution even?

---

## 2. Inspect node status before maintenance

```bash
kubectl get nodes -o wide
```

> What is the STATUS column for each node?

```bash
kubectl describe node kind-worker | head -60
```

> Find these sections:
> - `Conditions` — what does `Ready=True` mean?
> - `Capacity` vs `Allocatable` — what is the difference?
> - `Non-terminated Pods` — how many pods are running on this node?

---

## 3. Cordon a node

```bash
kubectl cordon kind-worker
```

```bash
kubectl get nodes
```

> What does the STATUS column show for `kind-worker` now?

```bash
kubectl describe node kind-worker | grep -A 3 Taints
```

> What taint was added? What effect does `node.kubernetes.io/unschedulable:NoSchedule` do?

---

## 4. Observe that existing pods are unaffected by cordon

```bash
kubectl get pods -n lab-24-maintenance -o wide
```

> Are the existing pods still running on `kind-worker`? Cordon only affects NEW pod scheduling.

---

## 5. Scale up — new pods avoid the cordoned node

```bash
kubectl scale deployment webapp --replicas=6 -n lab-24-maintenance
kubectl get pods -n lab-24-maintenance -o wide
```

> Where did the two new pods land? Why not on `kind-worker`?

---

## 6. Scale back to 4

```bash
kubectl scale deployment webapp --replicas=4 -n lab-24-maintenance
```

---

## 7. Drain the node

```bash
kubectl drain kind-worker \
  --ignore-daemonsets \
  --delete-emptydir-data
```

> What happens during drain? Watch the output closely:
> - Which pods are evicted?
> - Which pods are ignored (DaemonSet pods)?

```bash
kubectl get pods -n lab-24-maintenance -o wide
```

> Where are all the webapp pods now? Where are the node-monitor DaemonSet pods?

---

## 8. Inspect the drained node

```bash
kubectl get nodes
kubectl describe node kind-worker | grep -A 5 Taints
```

> What taints are on `kind-worker` now? Drain automatically cordons the node before evicting pods.

---

## 9. Simulate maintenance complete — uncordon

```bash
kubectl uncordon kind-worker
```

```bash
kubectl get nodes
kubectl get pods -n lab-24-maintenance -o wide
```

> Did pods automatically rebalance back to `kind-worker`? Why or why not?
> If not, what would cause pods to move back?

---

## 10. Apply the PodDisruptionBudget

```bash
kubectl apply -f manifests/pdb.yaml
```

```bash
kubectl get pdb -n lab-24-maintenance
```

> The output shows: NAME, MIN AVAILABLE, MAX UNAVAILABLE, ALLOWED DISRUPTIONS, AGE.
> With 4 replicas running and minAvailable=3, what is ALLOWED DISRUPTIONS?

---

## 11. Verify the PDB math

```bash
kubectl describe pdb webapp-pdb -n lab-24-maintenance
```

> Find: `Current number of pods`, `Minimum number of pods that must be available`, `Number of pods currently disrupted`.
> Based on this, can you drain a node right now?

---

## 12. Break it: drain with PDB active

Cordon `kind-worker2` first, then try to drain it:

```bash
kubectl cordon kind-worker2
kubectl drain kind-worker2 \
  --ignore-daemonsets \
  --delete-emptydir-data
```

> What error appears? The drain blocks and retries.
> Press Ctrl+C to stop the drain attempt.

```bash
kubectl uncordon kind-worker2
```

> Read the error message. Which pod could not be evicted and why?

---

## 13. Fix it: three ways to resolve a PDB conflict

**Option A — Scale up the deployment first, then drain**

```bash
kubectl scale deployment webapp --replicas=6 -n lab-24-maintenance
kubectl get pdb -n lab-24-maintenance  # ALLOWED DISRUPTIONS should be > 0 now
kubectl drain kind-worker2 --ignore-daemonsets --delete-emptydir-data
kubectl uncordon kind-worker2
kubectl scale deployment webapp --replicas=4 -n lab-24-maintenance
```

> After scaling to 6, what did ALLOWED DISRUPTIONS change to?

**Option B — Temporarily relax the PDB**

```bash
# Set a more permissive PDB (or delete it temporarily)
kubectl patch pdb webapp-pdb -n lab-24-maintenance \
  --type=merge \
  -p '{"spec":{"minAvailable":1}}'
kubectl drain kind-worker2 --ignore-daemonsets --delete-emptydir-data
kubectl apply -f manifests/pdb.yaml  # restore original PDB
kubectl uncordon kind-worker2
```

**Option C — Force drain (UNSAFE — skips PDB check)**

```bash
# Do NOT run this in production without explicit sign-off
# kubectl drain kind-worker2 --ignore-daemonsets --delete-emptydir-data --force --disable-eviction
```

> Why is Option C dangerous? When would you use it?

---

## 14. Observe node conditions under pressure

```bash
kubectl describe node kind-worker | grep -A 20 Conditions
```

> What conditions exist besides `Ready`? What would `MemoryPressure=True` mean for scheduling?

---

## 15. The kubeadm upgrade workflow — conceptual reference

On a real kubeadm cluster, the upgrade procedure for a worker node is:

```bash
# On the WORKER node:
# 1. Upgrade kubeadm
apt-mark unhold kubeadm && apt-get install -y kubeadm=1.XX.0-* && apt-mark hold kubeadm

# 2. Apply the upgrade
kubeadm upgrade node

# From kubectl on any control-plane or admin machine:
# 3. Drain the node (evacuate pods)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Back on the WORKER node:
# 4. Upgrade kubelet and kubectl
apt-mark unhold kubelet kubectl && \
  apt-get install -y kubelet=1.XX.0-* kubectl=1.XX.0-* && \
  apt-mark hold kubelet kubectl

# 5. Restart kubelet
systemctl daemon-reload && systemctl restart kubelet

# From kubectl:
# 6. Uncordon the node
kubectl uncordon <node-name>
```

> Identify which of these steps you practiced in this lab.
> Why must you drain before upgrading kubelet?
> What does `apt-mark hold` prevent?
