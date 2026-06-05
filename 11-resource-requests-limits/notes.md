# Lab Notes — 11 Resource Requests and Limits

Answer each question after running the lab.

---

## What I Expected

> What did you think resource requests and limits did before this lab?

---

## What Actually Happened

> Describe what you observed for each pod scenario.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Requests vs Limits

**What is the difference between a resource request and a resource limit?**

> Write your answer here.

**How does the scheduler use resource requests?**

> Write your answer here.

**What happens if a container exceeds its memory limit?**

> Write your answer here.

**What happens if a container exceeds its CPU limit?**

> Write your answer here.

---

## QoS Classes

**What QoS class did `pod-guaranteed` have, and why?**

> Write your answer here.

**What QoS class did `pod-burstable` have, and why?**

> Write your answer here.

**What QoS class did `pod-besteffort` have, and why?**

> Write your answer here.

**Which QoS class is evicted first when a node runs out of memory?**

> Write your answer here.

---

## The Unschedulable Pod

**What message appeared in the pod's Events when it could not be scheduled?**

> Write your answer here.

**Why can the scheduler not place a pod that requests 100Gi of memory?**

> Write your answer here.

---

## OOMKilled

**What happened to `pod-oom` after the container started?**

> Write your answer here.

**What did you see in the `Last State` section of `kubectl describe pod`?**

> Write your answer here.

**What does OOMKilled mean at the OS level?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## What This Means

> Explain why setting resource requests is important even if your containers are unlikely to use much CPU or memory.

---

## Things I Still Need to Research

> Write your answer here.
