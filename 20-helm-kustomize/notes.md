# Lab Notes — 20 Helm & Kustomize

Answer each question after running the lab.

---

## What I Expected

> Before this lab, what did you think the difference between Helm and Kustomize was? Had you used either before?

---

## What Actually Happened

> Describe what surprised you most about how Kustomize overlays work. What about Helm releases?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Kustomize

**What is a base in Kustomize? What is an overlay?**

> Write your answer here.

**How did the dev and prod Deployments differ from the base Deployment?**

> Write your answer here.

**What does `namePrefix` do in a Kustomize overlay?**

> Write your answer here.

**What does the `images` field in a kustomization.yaml do? Why is this better than editing the base deployment.yaml directly?**

> Write your answer here.

**What is the difference between a strategic merge patch and a JSON 6902 patch?**

> Write your answer here.

**What is `kubectl kustomize` doing, and how is it different from `kubectl apply -k`?**

> Write your answer here.

---

## Helm

**What is a Helm chart? What is a Helm release?**

> Write your answer here.

**What does `helm install` do that `kubectl apply` does not?**

> Write your answer here.

**After rollback, the revision number was NOT 1. What was it, and why?**

> Write your answer here.

**What does `helm get values` show? When would you use it?**

> Write your answer here.

**What is the difference between `--set` and `--values`?**

> Write your answer here.

---

## Helm vs Kustomize

**In your own words, when would you choose Helm over Kustomize?**

> Write your answer here.

**When would you choose Kustomize over Helm?**

> Write your answer here.

**Is there any reason to use both in the same project?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## Things I Still Need to Research

> Write your answer here.
