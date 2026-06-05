# Lab Notes — 13 DaemonSets, Jobs, and CronJobs

Answer each question after running the lab.

---

## What I Expected

> What did you think DaemonSets, Jobs, and CronJobs were before this lab?

---

## What Actually Happened

> Describe what each workload type did when you applied it.

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## DaemonSets

**What does a DaemonSet guarantee about pod placement?**

> Write your answer here.

**How many DaemonSet pods ran in your cluster, and why?**

> Write your answer here.

**What would happen if you added a new node to the cluster while the DaemonSet was running?**

> Write your answer here.

**Why did the DaemonSet pod land on the control-plane node? What made that possible?**

> Write your answer here.

**Give a real-world example of when you would use a DaemonSet.**

> Write your answer here.

---

## Jobs

**What is the difference between a Job and a Deployment?**

> Write your answer here.

**What do `completions` and `parallelism` control?**

> Write your answer here.

**What does `backoffLimit` do?**

> Write your answer here.

**After a Job completes, what happens to its pods?**

> Write your answer here.

---

## The Broken Job

**What happened when the Job's container exited with code 1?**

> Write your answer here.

**How many pods did the broken Job create in total?**

> Write your answer here.

**What status did the Job reach after exhausting retries?**

> Write your answer here.

---

## CronJobs

**What does a CronJob do that a Job alone cannot?**

> Write your answer here.

**What does `concurrencyPolicy: Forbid` prevent?**

> Write your answer here.

**What does `successfulJobsHistoryLimit` control?**

> Write your answer here.

**What happened when you suspended the CronJob?**

> Write your answer here.

---

## What This Means

> Name one use case each for a DaemonSet, a Job, and a CronJob. Explain why each workload type is the right fit.

---

## Things I Still Need to Research

> Write your answer here.
