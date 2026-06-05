# Lab Notes — 01 Pods

Answer each question after running the lab. Write in your own words.

---

## What I Expected

> What did you think a pod was before this lab? How did your mental model change?

---

## What Actually Happened

> Describe the pod lifecycle you observed. What states did it move through?

---

## Commands I Used

> List the commands you ran. For each one, write what object or resource it touched.

---

## Objects or Resources I Touched

> What Kubernetes objects did you create or modify in this lab?

---

## Pod Inspection

**What does `kubectl describe pod` show that `kubectl get pod` does not?**

> Write your answer here.

**What is in the `Events` section of a pod describe output?**

> Write your answer here.

**Where do pod logs come from?**

> Write your answer here.

---

## The Broken Pod

**What error appeared when you applied the bad image pod?**

> Write your answer here.

**What does `ImagePullBackOff` mean?**

> Write your answer here.

**What is the difference between `ErrImagePull` and `ImagePullBackOff`?**

> Write your answer here.

---

## Self-Healing

**What happened after you deleted the nginx-pod?**

> Write your answer here.

**Why did it not come back?**

> Write your answer here.

**What Kubernetes object would you need to add to make a pod self-heal after deletion?**

> Write your answer here.

---

## What Changed in the Cluster

> What existed in the cluster at the end of the lab that was not there before?

---

## What Broke

> Describe the ImagePullBackOff scenario.

---

## How I Fixed It

> How did you fix the broken pod? What command(s) did you use?

---

## What This Means

> In two or three sentences: explain what a pod is and why it is the smallest deployable unit in Kubernetes.

---

## Things I Still Need to Research

> Write your answer here.
