# 00 — First Multinode Cluster with kind

**Goal:** Create a local Kubernetes cluster, inspect its nodes, understand the control plane vs workers, and destroy/recreate it cleanly.

Do not deploy apps yet. This lab is only about the cluster itself.

**kind documentation:** https://kind.sigs.k8s.io/docs/user/quick-start/

---

## What You Will Build

```
my-first-cluster
├── control-plane node
├── worker node
└── worker node
```

---

## Prerequisites

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- Docker running

---

## Steps

### 1. Create the cluster

```bash
kind create cluster --config kind-config.yaml
```

This reads `kind-config.yaml` which defines 1 control-plane node and 2 worker nodes named `my-first-cluster`.

### 2. Work through the commands

Open [`commands.md`](commands.md) and run each command in order. Read the output carefully.

### 3. Fill in your notes

Open [`notes.md`](notes.md) and answer every question in your own words before moving on.

### 4. Clean up

```bash
./cleanup.sh
```

Or manually:

```bash
kind delete cluster --name my-first-cluster
```

---

## Files

| File | Purpose |
|------|---------|
| `kind-config.yaml` | Cluster definition: 1 control-plane + 2 workers |
| `commands.md` | Ordered list of commands to practice |
| `notes.md` | Questions to answer after running the lab |
| `cleanup.sh` | Deletes the cluster |

---

## Rule

You are done with this lab when you can create, inspect, explain, and delete the cluster without looking anything up.

Next lab: `01-pods`
