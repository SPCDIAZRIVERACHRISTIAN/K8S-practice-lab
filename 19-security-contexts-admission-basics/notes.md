# Lab Notes — 19 Security Contexts & Pod Security Admission

Answer each question after running the lab.

---

## What I Expected

> Before this lab, what did you think happened when a pod tried to run as root? Did you know Kubernetes could block that at admission time?

---

## What Actually Happened

> Describe what happened when you applied the broken pods. Were the rejection messages clear? Could you tell exactly which field to fix?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## securityContext Fields

**What does `runAsNonRoot: true` do? Where does the container image's user come from?**

> Write your answer here.

**What is `readOnlyRootFilesystem`? Why is /tmp still writable in the secure pod?**

> Write your answer here.

**What does `allowPrivilegeEscalation: false` block specifically?**

> Write your answer here.

**What are Linux capabilities? Why does the `restricted` level require `capabilities.drop: ["ALL"]`?**

> Write your answer here.

**What is the difference between pod-level securityContext and container-level securityContext?**

> Write your answer here.

---

## Pod Security Admission

**What is Pod Security Admission (PSA)? When was it introduced?**

> Write your answer here.

**What are the three PSA levels? What does each one block?**

> Write your answer here.

**What are the three PSA modes? What does each one do?**

> Write your answer here.

**How do you enable PSA enforcement on a namespace?**

> Write your answer here.

**What happened when you set warn mode instead of enforce mode?**

> Write your answer here.

---

## Break / Fix

**pod-root.yaml was rejected. What specific field(s) were missing that caused the rejection?**

> Write your answer here.

**pod-privileged.yaml violated even the baseline level. What does privileged mode give a container?**

> Write your answer here.

**pod-missing-caps-drop.yaml was rejected only in restricted. Why does baseline not require capability drops?**

> Write your answer here.

---

## seccompProfile

**What is seccomp? What does `RuntimeDefault` mean?**

> Write your answer here.

**Why is seccompProfile required by the restricted level but not baseline?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## Things I Still Need to Research

> Write your answer here.
