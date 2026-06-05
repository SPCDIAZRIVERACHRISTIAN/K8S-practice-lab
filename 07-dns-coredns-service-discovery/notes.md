# Lab Notes — 07 DNS and CoreDNS Service Discovery

Answer each question after running the lab.

---

## What I Expected

> What did you think happened when a pod "calls" a service by name?

---

## What Actually Happened

> Describe what you observed for each DNS form you tried.

---

## Commands I Used

> List the commands you ran and what each one revealed.

---

## Objects or Resources I Touched

> Write your answer here.

---

## DNS Forms

**Result of `wget backend` from the frontend pod:**

> Write your answer here.

**Result of `wget backend.lab-07-backend` from the frontend pod:**

> Write your answer here.

**Result of `wget backend.lab-07-backend.svc.cluster.local` from the frontend pod:**

> Write your answer here.

---

## Understanding the DNS Hierarchy

**What is the full DNS format for a Kubernetes service?**

> Write your answer here.

**What does `/etc/resolv.conf` inside a pod contain? Why does it matter?**

> Write your answer here.

**What is the `search` domain in `/etc/resolv.conf` and how does it help short names resolve?**

> Write your answer here.

---

## CoreDNS

**What is CoreDNS and where does it run?**

> Write your answer here.

**What IP does a pod use as its DNS server? How did you verify this?**

> Write your answer here.

**What is the cluster domain in your kind cluster?**

> Write your answer here.

---

## Cross-Namespace DNS

**When does the short name form (`service-name` only) work?**

> Write your answer here.

**When should you always use the full FQDN?**

> Write your answer here.

---

## What Changed in the Cluster

> Write your answer here.

---

## What This Means

> Explain why hardcoding pod IPs in your application config is a bad idea, and how DNS-based service discovery solves this.

---

## Things I Still Need to Research

> Write your answer here.
