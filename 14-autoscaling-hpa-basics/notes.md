# Lab Notes — 14 Autoscaling: HPA Basics

Answer each question after running the lab.

---

## What I Expected

> What did you think the HPA did before this lab?

---

## What Actually Happened

> Describe the scaling behavior you observed under load and after stopping load.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## metrics-server

**What does metrics-server do?**

> Write your answer here.

**Why does kind need a special flag (`--kubelet-insecure-tls`) for metrics-server?**

> Write your answer here.

---

## HPA Mechanics

**How does the HPA calculate whether to scale up or down?**

> Write your answer here.

**Why are CPU requests required for CPU-based HPA to work?**

> Write your answer here.

**What happened to the HPA's TARGETS column when CPU requests were removed?**

> Write your answer here.

---

## Scaling Behavior

**How long did it take for the HPA to scale up after load started?**

> Write your answer here.

**How long did it take for the HPA to scale back down after load stopped?**

> Write your answer here.

**What is the purpose of the scale-down cooldown period?**

> Write your answer here.

---

## Limits

**What is `minReplicas` and `maxReplicas` for?**

> Write your answer here.

**What would happen if every pod was at 200% CPU but maxReplicas was already reached?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## What This Means

> Explain why setting CPU requests is a prerequisite for autoscaling, not just a nice-to-have.

---

## Things I Still Need to Research

> Write your answer here.
