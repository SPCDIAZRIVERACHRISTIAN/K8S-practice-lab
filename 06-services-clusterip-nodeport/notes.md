# Lab Notes — 06 Services: ClusterIP and NodePort

Answer each question after running the lab.

---

## What I Expected

> What did you think a Kubernetes Service was before this lab?

---

## What Actually Happened

> Describe what you observed about how Services connect to pods.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Why Services Exist

**Why are pod IPs considered unstable?**

> Write your answer here.

**What problem does a ClusterIP Service solve?**

> Write your answer here.

---

## ClusterIP vs NodePort

**What is a ClusterIP Service accessible from?**

> Write your answer here.

**What is a NodePort Service accessible from?**

> Write your answer here.

**When would you use NodePort instead of ClusterIP?**

> Write your answer here.

---

## Endpoints

**What is a Kubernetes Endpoint (or EndpointSlice)?**

> Write your answer here.

**How does a Service know which pods to route traffic to?**

> Write your answer here.

**When you deleted a pod and it was replaced, what happened to the Service endpoints?**

> Write your answer here.

---

## The Broken Selector

**What was wrong with `service-bad-selector.yaml`?**

> Write your answer here.

**How did you identify the mismatch?**

> Write your answer here.

**What command showed you the pods' labels?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## What Broke

> Describe the broken selector scenario.

---

## How I Fixed It

> Write your answer here.

---

## What This Means

> Why is a label-selector typo one of the most common sources of "service not working" bugs?

---

## Things I Still Need to Research

> Write your answer here.
