# Lab Notes — 17 StatefulSets

Answer each question after running the lab.

---

## What I Expected

> What did you think StatefulSets were before this lab? How did you expect them to differ from Deployments?

---

## What Actually Happened

> Describe the pod startup order, the PVC naming, and what happened when you deleted and recreated web-1.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Pod Identity

**What are the pod names in a StatefulSet? How are they different from Deployment pod names?**

> Write your answer here.

**What happened to the pod name when you deleted web-1?**

> Write your answer here.

**What is ordinal identity and why does it matter for stateful applications?**

> Write your answer here.

---

## Ordered Startup and Shutdown

**In what order did the pods start?**

> Write your answer here.

**In what order were the pods removed when you scaled down?**

> Write your answer here.

**Why does a StatefulSet start and stop pods in order?**

> Write your answer here.

---

## volumeClaimTemplates

**What does `volumeClaimTemplates` do?**

> Write your answer here.

**How are the PVCs named?**

> Write your answer here.

**What happened to the PVCs when you scaled down?**

> Write your answer here.

**What does it mean that PVCs outlive their pods in a StatefulSet?**

> Write your answer here.

---

## Headless Service and DNS

**What is a headless Service (clusterIP: None)?**

> Write your answer here.

**What DNS name does each pod get?**

> Write your answer here.

**What did `nslookup web.lab-17-statefulsets.svc.cluster.local` return?**

> Write your answer here.

---

## StatefulSet vs Deployment

**Name two situations where you would choose a StatefulSet over a Deployment.**

> Write your answer here.

**Name two situations where a Deployment is the right choice.**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## Things I Still Need to Research

> Write your answer here.
