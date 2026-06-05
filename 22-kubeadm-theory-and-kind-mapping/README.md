# Lab 22 — kubeadm Theory & kind Mapping

## Goal

Understand how kubeadm bootstraps a Kubernetes cluster, where control plane components live, how certificates are structured, and how static pods work — all by inspecting the live kind cluster that kubeadm already set up for you.

kind uses kubeadm internally to bootstrap every cluster. Everything kubeadm produces is visible inside the kind control-plane container.

## Teaches

- What kubeadm does during `kubeadm init` (phases, outputs, files it creates)
- Control plane components: kube-apiserver, kube-controller-manager, kube-scheduler, etcd
- Static pods: why control plane components are not managed by the kubelet's normal pod lifecycle
- Where static pod manifests live (`/etc/kubernetes/manifests/`)
- Kubernetes PKI structure: what each certificate is for, how to check expiry
- kubeconfig files: cluster, user, context — how kubectl knows where to talk
- kubelet configuration and the node agent
- How worker nodes join a cluster (`kubeadm join`, bootstrap tokens)
- `kubeadm certs check-expiration` — the exam command for cert auditing

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`)
- Docker running
- No additional tools needed — all inspection uses `docker exec` and `kubectl`

## What You Will Do

This is an **inspection lab** — no manifests to apply, no namespace to create. You will:

1. Identify the control plane components running as pods in `kube-system`
2. Exec into the kind control-plane container to read static pod manifests
3. Inspect the PKI directory and certificate expiry
4. Read kubeconfig files and understand their structure
5. Inspect kubelet configuration on both the control-plane and worker nodes
6. Observe how `kubeadm certs check-expiration` audits the full certificate chain
7. Map each kubeadm concept to a real production kubeadm cluster

## Files

```
commands.md   — all inspection commands with observation questions
notes.md      — blank workbook
solutions.md  — explanations, kubeadm phase walkthrough, cert reference table
cleanup.sh    — no-op (nothing created)
```

## Success Criteria

- You can name all four control plane components and say where they run
- You can read a static pod manifest and explain why static pods are special
- You can run `kubeadm certs check-expiration` and interpret the output
- You can identify the CA cert, API server cert, and etcd peer cert in `/etc/kubernetes/pki/`
- You can explain what a kubeconfig's `server`, `certificate-authority-data`, `client-certificate-data` fields mean
- You can describe the six phases of `kubeadm init` from memory

## Difficulty

Hard — not because the commands are complex, but because this material requires building a mental model of the Kubernetes control plane architecture that connects many pieces you've used separately.
