# Lab Notes — 22 kubeadm Theory & kind Mapping

Answer each question after running the lab.

---

## What I Expected

> Before this lab, did you know the control plane components ran as pods? Did you know where their manifests were stored?

---

## What Actually Happened

> What was the most surprising thing you found when inspecting the kind control-plane container?

---

## Commands I Used

> List the commands you ran and what each one showed you.

---

## Objects or Resources I Touched

> Write your answer here.

---

## Control Plane Components

**Name the four core control plane components. What does each one do?**

> Write your answer here.

**Where do these components run in a kind cluster vs a production kubeadm cluster?**

> Write your answer here.

**What is kube-proxy? Is it a control plane component? Where does it run?**

> Write your answer here.

---

## Static Pods

**What is a static pod? How is it different from a regular pod?**

> Write your answer here.

**What manages static pods? What happens when you delete a static pod?**

> Write your answer here.

**Where does kubelet look for static pod manifests?**

> Write your answer here.

**Why are control plane components run as static pods instead of Deployments?**

> Write your answer here.

---

## PKI and Certificates

**What is the Kubernetes root CA (`ca.crt`)? Why does everything else trust it?**

> Write your answer here.

**What certificate does the API server present to clients? What Subject Alternative Names did it have?**

> Write your answer here.

**What is the difference between a CA certificate and a component certificate?**

> Write your answer here.

**What command do you run to check certificate expiry on a kubeadm cluster?**

> Write your answer here.

**What happens if a certificate expires?**

> Write your answer here.

---

## kubeconfig Files

**What are the three main fields in a kubeconfig that tell kubectl where to connect and how to authenticate?**

> Write your answer here.

**Which kubeconfig file is used by the controller-manager? By the scheduler?**

> Write your answer here.

**What is the `admin.conf` file used for?**

> Write your answer here.

---

## kubeadm Phases

**List the kubeadm init phases in order and what artifact or action each one produces.**

> Write your answer here.

**What does `kubeadm join` do? What information does a worker node need to join a cluster?**

> Write your answer here.

**What is a bootstrap token?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here. (This lab is read-only except for the deleted etcd pod which auto-recovered.)

---

## Things I Still Need to Research

> Write your answer here.
