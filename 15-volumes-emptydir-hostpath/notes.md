# Lab Notes — 15 Volumes: emptyDir and hostPath

Answer each question after running the lab.

---

## What I Expected

> What did you think a Kubernetes volume was before this lab?

---

## What Actually Happened

> Describe what happened to the data in each scenario: emptyDir after pod deletion, hostPath after pod deletion.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## emptyDir

**What is an emptyDir volume?**

> Write your answer here.

**Where is the emptyDir backed on disk?**

> Write your answer here.

**What happened to the data after the emptyDir pod was deleted?**

> Write your answer here.

**When would you use emptyDir? Give a concrete example.**

> Write your answer here.

---

## hostPath

**What is a hostPath volume?**

> Write your answer here.

**What happened to the data after the hostPath pod was deleted and recreated?**

> Write your answer here.

**Why would the data NOT be there if the pod rescheduled to a different node?**

> Write your answer here.

**What security risk does hostPath introduce?**

> Write your answer here.

---

## Shared emptyDir

**How did the two containers in the shared-volume pod communicate?**

> Write your answer here.

**What would happen to the shared data if the entire pod was restarted?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## What This Means

> Explain why neither emptyDir nor hostPath is appropriate for a database that needs durable storage across pod restarts and rescheduling. What type of storage would you need instead?

---

## Things I Still Need to Research

> Write your answer here.
