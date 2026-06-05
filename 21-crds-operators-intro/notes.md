# Lab Notes — 21 CRDs & Operators Intro

Answer each question after running the lab.

---

## What I Expected

> Before this lab, what did you think CRDs were used for? Did you think they were only for advanced users, or did you realize most production clusters already have dozens of them?

---

## What Actually Happened

> What surprised you most about CRDs? When you created the Widget resource, were you expecting something to happen in the cluster?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Custom Resource Definitions

**What does a CRD do at a technical level?**

> Write your answer here.

**What are the three main sections of a CRD spec?**

> Write your answer here.

**What is `scope: Namespaced` vs `scope: Cluster`? Give an example of a built-in resource at each scope.**

> Write your answer here.

**What are `additionalPrinterColumns`? How are they different from `.spec` or `.status` fields?**

> Write your answer here.

---

## Schema Validation

**What schema violations caused each broken widget to be rejected?**

> Write your answer here.

**When does schema validation happen — before or after the resource is stored in etcd?**

> Write your answer here.

**What would happen if you created a CRD with no schema (`openAPIV3Schema` omitted)?**

> Write your answer here.

---

## CRDs vs Operators

**After creating a Widget resource, nothing happened in the cluster. What is missing?**

> Write your answer here.

**What is a controller? What does it watch for?**

> Write your answer here.

**What is the difference between a CRD and an operator?**

> Write your answer here.

**Give an example of a real operator you have heard of or used. What Kubernetes objects does it manage?**

> Write your answer here.

---

## What happened when you deleted the CRD?

> Write your answer here.

**What does this tell you about the relationship between a CRD and its custom resources?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## Things I Still Need to Research

> Write your answer here.
