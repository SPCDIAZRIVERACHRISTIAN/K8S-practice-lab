# Lab Notes — 09 Network Policies

Answer each question after running the lab. This lab is in its own cluster — make sure your context is correct throughout.

---

## What I Expected

> What did you think a NetworkPolicy did before this lab?

---

## What Actually Happened

> Describe what happened to traffic at each stage: before policy, after deny-all, after allow-frontend.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Why a Separate Cluster

**Why can't we use the main kind cluster for this lab?**

> Write your answer here.

**What is kindnet and why doesn't it enforce NetworkPolicy?**

> Write your answer here.

**What does Calico add that kindnet does not provide?**

> Write your answer here.

---

## NetworkPolicy Mechanics

**What is a `podSelector` in a NetworkPolicy?**

> Write your answer here.

**What does a NetworkPolicy with `policyTypes: [Ingress]` and NO ingress rules do?**

> Write your answer here.

**What is the relationship between the deny-all policy and the allow-frontend policy?**

> Write your answer here.

---

## Test Results

**Before any policy — frontend-pod to backend:**

> Write your answer here.

**Before any policy — other-pod to backend:**

> Write your answer here.

**After deny-all — frontend-pod to backend:**

> Write your answer here.

**After deny-all — other-pod to backend:**

> Write your answer here.

**After allow-frontend — frontend-pod to backend:**

> Write your answer here.

**After allow-frontend — other-pod to backend:**

> Write your answer here.

---

## Direct Pod IP vs Service

**Does NetworkPolicy apply when connecting to a pod directly by IP, or only through a Service?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## What This Means

> Explain the default Kubernetes networking model: without NetworkPolicy, what can any pod reach?

---

## Things I Still Need to Research

> Write your answer here.
