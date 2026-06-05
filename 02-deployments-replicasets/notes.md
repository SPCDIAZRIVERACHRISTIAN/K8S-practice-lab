# Lab Notes — 02 Deployments and ReplicaSets

Answer each question after running the lab.

---

## What I Expected

> What did you think a Deployment did before this lab?

---

## What Actually Happened

> Describe what happened when you applied the Deployment. What objects appeared?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> What Kubernetes objects were created in this lab?

---

## The Deployment → ReplicaSet → Pod Chain

**What is the relationship between a Deployment, a ReplicaSet, and a Pod?**

> Write your answer here.

**When you deleted a pod, what created the replacement?**

> Write your answer here.

**How does the ReplicaSet know which pods it owns?**

> Write your answer here.

---

## Scaling

**What changed in the cluster when you scaled from 3 to 5?**

> Write your answer here.

**What happened to the ReplicaSet when you scaled down?**

> Write your answer here.

---

## The Broken Selector

**What error appeared when you applied the broken selector manifest?**

> Write your answer here (paste the full error message).

**Why does Kubernetes reject a Deployment where the selector does not match the template labels?**

> Write your answer here.

---

## What Changed in the Cluster

> What objects existed at the end of the lab that were not there at the start?

---

## What Broke

> Describe what the broken selector manifest was trying to do and why it failed.

---

## What This Means

> In two or three sentences: explain why a Deployment is more useful than a standalone pod.

---

## Things I Still Need to Research

> Write your answer here.
