# Lab Notes — 24 Upgrades & Node Maintenance

Answer each question after running the lab.

---

## What I Expected

> Before this lab, did you know the difference between cordon and drain? Did you know PDBs could block a drain?

---

## What Actually Happened

> Describe what happened when the PDB blocked your drain attempt. What did the error say?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Cordon

**What does `kubectl cordon` do? What taint does it add?**

> Write your answer here.

**Does cordon affect existing pods already running on the node?**

> Write your answer here.

**When would you use cordon without drain?**

> Write your answer here.

---

## Drain

**What does `kubectl drain` do? What are the two steps it takes?**

> Write your answer here.

**What does `--ignore-daemonsets` do? Why is it usually required?**

> Write your answer here.

**What does `--delete-emptydir-data` do? What data is lost when a pod with emptyDir is evicted?**

> Write your answer here.

**Why did the DaemonSet pods remain on the node during drain?**

> Write your answer here.

**After uncordon, did pods automatically rebalance back to the previously drained node? Why or why not?**

> Write your answer here.

---

## PodDisruptionBudget

**What does a PodDisruptionBudget do?**

> Write your answer here.

**What is `minAvailable`? What is `maxUnavailable`?**

> Write your answer here.

**With 4 replicas and minAvailable: 3, what is ALLOWED DISRUPTIONS? Show the math.**

> Write your answer here.

**Why did the drain block? What specific condition was violated?**

> Write your answer here.

**Describe the three ways to resolve a PDB conflict. Which is safest?**

> Write your answer here.

**When would you use `--force --disable-eviction` on drain? What is the risk?**

> Write your answer here.

---

## Node Conditions

**What does `Ready=True` mean on a node? What would `Ready=False` look like?**

> Write your answer here.

**What is the difference between `Capacity` and `Allocatable` on a node?**

> Write your answer here.

**What does `MemoryPressure=True` trigger on a node?**

> Write your answer here.

---

## kubeadm Upgrade

**In what order do you upgrade a kubeadm worker node? List the steps.**

> Write your answer here.

**Why must you drain a worker node before upgrading kubelet?**

> Write your answer here.

**Why does the kubeadm upgrade guide use `apt-mark hold` on the packages?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## Things I Still Need to Research

> Write your answer here.
