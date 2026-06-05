# Lab Notes — 18 RBAC & ServiceAccounts

Answer each question after running the lab.

---

## What I Expected

> Before this lab, what did you think controlled whether a pod could talk to the Kubernetes API? Did you know pods have an identity at all?

---

## What Actually Happened

> Describe what happened when you ran `kubectl delete deployment` from inside the rbac-tester pod. What did you expect, and what did you see?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## ServiceAccounts

**What is a ServiceAccount and what problem does it solve?**

> Write your answer here.

**Where is the ServiceAccount token mounted inside a pod? What three files are in that directory?**

> Write your answer here.

**What happens if you do not specify a `serviceAccountName` in a pod spec?**

> Write your answer here.

---

## Roles and Rules

**What are the three parts of an RBAC rule?**

> Write your answer here.

**What does `apiGroups: [""]` mean? What is the core API group?**

> Write your answer here.

**Why can the pod-reader Role list pods but not delete deployments, even though both are Kubernetes objects?**

> Write your answer here.

---

## Role vs ClusterRole

**What is the difference between a Role and a ClusterRole?**

> Write your answer here.

**Can you use a ClusterRole with a RoleBinding? What does that do?**

> Write your answer here.

**When would you use a ClusterRoleBinding instead of a RoleBinding?**

> Write your answer here.

---

## kubectl auth can-i

**What does the `--as` flag do in `kubectl auth can-i`?**

> Write your answer here.

**What is the full format for impersonating a ServiceAccount?**

> Write your answer here.

**Why did the ServiceAccount fail to list pods in the `default` namespace even though the Role allowed listing pods?**

> Write your answer here.

---

## Break / Fix

**When you applied the empty Role, why did permissions change immediately without touching the RoleBinding?**

> Write your answer here.

**When you applied the RoleBinding with the wrong subject name, the Role was correct but access was still denied. Why?**

> Write your answer here.

**What does this tell you about the three things you must check when RBAC is denying access?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## Things I Still Need to Research

> Write your answer here.
