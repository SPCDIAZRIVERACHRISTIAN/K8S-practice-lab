# Lab Notes — 05 Health Checks and Probes

Answer each question after running the lab.

---

## What I Expected

> What did you think readiness and liveness probes did before this lab?

---

## What Actually Happened

> Describe what happened to the broken probe pods. What state did they end up in?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Probe Types

**What is the difference between a readinessProbe and a livenessProbe?**

> Write your answer here.

**What happens to a pod when the readinessProbe fails?**

> Write your answer here.

**What happens to a pod when the livenessProbe fails?**

> Write your answer here.

---

## The Broken Probes

**Why did `/healthz` cause the readiness probe to fail?**

> Write your answer here.

**Why did port `9090` cause the liveness probe to fail?**

> Write your answer here.

**What did the pod's RESTARTS counter show after several minutes?**

> Write your answer here.

---

## Endpoints and Traffic

**When the pods were not Ready, were they listed as endpoints for the Service?**

> Write your answer here.

**What does it mean for a Service when a pod's readiness probe fails?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## What Broke

> Describe both probe failures: what was broken and what symptom it caused.

---

## How I Fixed It

> Write your answer here.

---

## What This Means

> Explain why you would use a readinessProbe on a web server that takes 10 seconds to load its configuration before it can serve traffic.

---

## Things I Still Need to Research

> Write your answer here.
