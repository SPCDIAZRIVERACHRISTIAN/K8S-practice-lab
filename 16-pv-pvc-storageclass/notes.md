# Lab Notes — 16 PersistentVolumes, PersistentVolumeClaims, and StorageClass

Answer each question after running the lab.

---

## What I Expected

> What did you think PVCs and PVs were before this lab?

---

## What Actually Happened

> Describe the lifecycle you observed: PVC created → PV provisioned → pod attached → data survived pod deletion.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## The Three-Layer Model

**What is a StorageClass?**

> Write your answer here.

**What is a PersistentVolume?**

> Write your answer here.

**What is a PersistentVolumeClaim?**

> Write your answer here.

**What is dynamic provisioning?**

> Write your answer here.

---

## PVC Lifecycle

**Why did the PVC stay Pending before the pod was created?**

> Write your answer here.

**What triggered the PVC to move from Pending to Bound?**

> Write your answer here.

**After you deleted the pod and recreated it, was the data still there?**

> Write your answer here.

**How is this different from emptyDir and hostPath?**

> Write your answer here.

---

## Access Modes

**What does `ReadWriteOnce` mean?**

> Write your answer here.

**What are the other access modes, and when would you use them?**

> Write your answer here.

---

## The Broken PVC

**What error appeared when you described the broken PVC?**

> Write your answer here.

**What happened to a pod that tried to mount the Pending PVC?**

> Write your answer here.

---

## Reclaim Policy

**What is the reclaim policy of the PV that was created?**

> Write your answer here.

**What happened to the PV after you deleted the PVC?**

> Write your answer here.

**What would `Retain` reclaim policy do differently?**

> Write your answer here.

---

## What This Means

> Explain the full path a request for storage takes: from writing `storageClassName: standard` in a PVC manifest to the data landing on disk somewhere.

---

## Things I Still Need to Research

> Write your answer here.
