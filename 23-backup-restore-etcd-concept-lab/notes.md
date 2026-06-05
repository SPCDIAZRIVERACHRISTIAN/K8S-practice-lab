# Lab Notes — 23 etcd Backup & Restore Concept Lab

Answer each question after running the lab.

---

## What I Expected

> Before this lab, did you know what etcd stored? Did you expect the data to be readable or binary?

---

## What Actually Happened

> What surprised you when you inspected the etcd keys? Was the data readable?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## What etcd stores

**What does etcd store? Give three examples of Kubernetes object types that live in etcd.**

> Write your answer here.

**Why is etcd the most critical component to back up?**

> Write your answer here.

**What happens to the cluster if etcd data is permanently lost?**

> Write your answer here.

**How does etcd store Kubernetes data? What key prefix did you observe?**

> Write your answer here.

---

## etcdctl commands

**Write the four flags required for every authenticated etcdctl command in a kubeadm cluster.**

> Write your answer here.

**What does `ETCDCTL_API=3` do? What happens if you omit it?**

> Write your answer here.

**Where do you find the exact cert paths if you forget them during an exam?**

> Write your answer here.

**What does `etcdctl endpoint status` show? What is the Revision field?**

> Write your answer here.

---

## Backup

**Write the `etcdctl snapshot save` command from memory (leave the cert values blank if needed).**

> Write your answer here.

**What does `etcdctl snapshot status` verify?**

> Write your answer here.

**Why must you copy the snapshot out of the container? Where should production snapshots be stored?**

> Write your answer here.

---

## Restore

**Why must the API server be stopped before restoring etcd?**

> Write your answer here.

**How do you stop the API server on a kubeadm cluster?**

> Write your answer here.

**What does `--data-dir` specify in the `etcdctl snapshot restore` command?**

> Write your answer here.

**After a restore completes, what cluster state is recovered? What is lost?**

> Write your answer here.

**After the restore, why do you need to edit the etcd static pod manifest?**

> Write your answer here.

---

## The restore sequence

**Without looking at commands.md, list the steps of the etcd restore procedure in order.**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## Things I Still Need to Research

> Write your answer here.
