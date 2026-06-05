# Lab Notes — 12 Node Selectors, Affinity, Taints, and Tolerations

Answer each question after running the lab.

---

## What I Expected

> What did you think pod scheduling was before this lab?

---

## What Actually Happened

> Describe what happened at each stage: nodeSelector before label, after label, taint without toleration, taint with toleration.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## nodeSelector

**What does `nodeSelector` do?**

> Write your answer here.

**What happened to the pod BEFORE the node was labeled?**

> Write your answer here.

**What message appeared in the Events when the pod was Pending?**

> Write your answer here.

---

## Node Affinity

**What is the difference between `requiredDuringScheduling` and `preferredDuringScheduling` affinity?**

> Write your answer here.

**What happened to the preferred affinity pod when the matching node label was removed?**

> Write your answer here.

---

## Taints and Tolerations

**What is a taint and what effect does it have on pods?**

> Write your answer here.

**What are the three taint effects? What does each one do?**

> Write your answer here.

**What is a toleration and how does it relate to a taint?**

> Write your answer here.

**Does a toleration guarantee a pod lands on the tainted node?**

> Write your answer here.

---

## Control-plane Taint

**What taint does the control-plane node have in kind?**

> Write your answer here.

**Why does Kubernetes apply this taint automatically?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## What This Means

> Explain when you would use a taint vs a nodeSelector to control pod placement. What is the semantic difference?

---

## Things I Still Need to Research

> Write your answer here.
