# Lab Notes — 03 Rollouts and Rollbacks

Answer each question after running the lab.

---

## What I Expected

> What did you think a rolling update meant before this lab?

---

## What Actually Happened

> Describe the rolling update process you observed. What did the pods do?

---

## Commands I Used

> List the commands you ran and what each one revealed.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Rolling Update Mechanics

**What happened to the old ReplicaSet during the rolling update?**

> Write your answer here.

**Why were there two ReplicaSets after the update?**

> Write your answer here.

**What do `maxSurge` and `maxUnavailable` control?**

> Write your answer here.

---

## Rollout History

**What is a revision in Kubernetes rollout history?**

> Write your answer here.

**What triggers a new revision?**

> Write your answer here.

---

## The Broken Update

**What happened when you pushed `nginx:badversion`?**

> Write your answer here.

**Did ALL pods get replaced with the bad image? Why or why not?**

> Write your answer here.

**What is the purpose of `maxUnavailable` in this scenario?**

> Write your answer here.

---

## The Rollback

**What did `kubectl rollout undo` actually do at the infrastructure level?**

> Write your answer here.

**After the rollback, what image were the pods running?**

> Write your answer here.

---

## What Changed in the Cluster

> What objects existed at the end of the lab?

---

## What Broke

> Describe the broken image scenario in detail.

---

## How I Fixed It

> Write your answer here.

---

## What This Means

> Explain why the rolling update strategy is safer than taking all pods down and replacing them at once.

---

## Things I Still Need to Research

> Write your answer here.
