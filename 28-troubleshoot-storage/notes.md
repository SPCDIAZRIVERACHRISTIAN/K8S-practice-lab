# Lab Notes — 28 Troubleshoot Storage

---

## What I Expected

> Did you expect PVC problems to be easy to diagnose? What did you think would happen when a StorageClass didn't exist?

---

## Commands I Used

> Write your answer here.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Scenario 1 — Wrong StorageClass

**What specific event appeared in `kubectl describe pvc`?**

> Write your answer here.

**Why can't you patch a PVC's storageClassName in place?**

> Write your answer here.

**What does `kubectl get storageclass` show in a kind cluster?**

> Write your answer here.

---

## Scenario 2 — Wrong Access Mode

**What is ReadWriteMany? What type of storage supports it?**

> Write your answer here.

**Why does kind's local-path provisioner only support ReadWriteOnce?**

> Write your answer here.

---

## Scenario 3 — Pod with Missing PVC

**What state was the pod in? What did the Events section say?**

> Write your answer here.

**After creating the PVC, did the pod recover automatically? How long did it take?**

> Write your answer here.

**What does this tell you about how Kubernetes handles missing volume dependencies?**

> Write your answer here.

---

## Scenario 4 — StatefulSet volumeClaimTemplates

**What error did you get when you tried to patch the volumeClaimTemplate?**

> Write your answer here.

**Why is volumeClaimTemplates immutable on a running StatefulSet?**

> Write your answer here.

**What was the correct fix procedure? What order did you perform the steps?**

> Write your answer here.

**What would happen to the data in the PVCs if you just deleted the StatefulSet without deleting the PVCs first?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## Things I Still Need to Research

> Write your answer here.
