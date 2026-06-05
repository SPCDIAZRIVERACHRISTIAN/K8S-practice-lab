# Lab Notes — 29 Troubleshoot Cluster Nodes

---

## What I Expected

> Before this lab, could you identify scheduling failures by reading `kubectl describe pod` output? What did you expect the error messages to look like?

---

## Commands I Used

> Write your answer here.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Scenario 1 — Taint without toleration

**What was the exact Events message in `kubectl describe pod`?**

> Write your answer here.

**Why couldn't you patch the toleration onto the pod in place?**

> Write your answer here.

**After adding the toleration and deleting/recreating the pod, which node did it schedule on? Why?**

> Write your answer here.

**What is the difference between NoSchedule, NoExecute, and PreferNoSchedule?**

> Write your answer here.

---

## Scenario 2 — Bad nodeSelector

**What was the exact Events message?**

> Write your answer here.

**When you added the label to kind-worker, did the Pending pod schedule immediately without being deleted? Why?**

> Write your answer here.

**What is the difference between nodeSelector and node affinity (required)?**

> Write your answer here.

---

## Scenario 3 — Bad node affinity

**What was the exact Events message?**

> Write your answer here.

**What is `requiredDuringSchedulingIgnoredDuringExecution` vs `preferredDuringSchedulingIgnoredDuringExecution`?**

> Write your answer here.

**"IgnoredDuringExecution" — what does this mean? What would happen if a node's labels changed after a pod was running on it?**

> Write your answer here.

---

## Node Conditions

**List the four main node conditions and what each one means when True.**

> Write your answer here.

**What is the difference between Capacity and Allocatable?**

> Write your answer here.

---

## Fast Triage Reference

**From memory, write the scheduling failure event message for each cause:**

| Cause | Event message fragment |
|-------|----------------------|
| Taint without toleration | |
| nodeSelector mismatch | |
| Required affinity mismatch | |
| Node cordoned | |
| Insufficient CPU/memory | |

---

## What Changed in the Cluster

> Write your answer here. (Were all taints and labels removed after cleanup?)

---

## Things I Still Need to Research

> Write your answer here.
