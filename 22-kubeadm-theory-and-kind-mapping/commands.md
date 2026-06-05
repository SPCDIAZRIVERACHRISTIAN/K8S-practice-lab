# Commands — 22 kubeadm Theory & kind Mapping

Work through each section. Every question in `notes.md` maps to an observation here.

---

## 1. Identify control plane components

```bash
kubectl get pods -n kube-system -o wide
```

> Which pods are on the control-plane node? Which are on worker nodes? What does `-o wide` add?

```bash
kubectl get pods -n kube-system --field-selector spec.nodeName=kind-control-plane
```

> List the four core control plane components. What does each one do?

---

## 2. Static pods — what they are

```bash
kubectl describe pod etcd-kind-control-plane -n kube-system | head -30
```

> Notice the pod name includes the node name. What is the `ownerReference` on this pod?
> Compare this to a regular Deployment pod — what is different?

```bash
kubectl describe pod etcd-kind-control-plane -n kube-system | grep "Controlled By"
```

> Static pods are controlled by `Node/<nodename>`, not by a ReplicaSet or Deployment. What does that mean for what happens if you delete a static pod?

Try it (the pod will be recreated immediately by kubelet):

```bash
kubectl delete pod etcd-kind-control-plane -n kube-system
kubectl get pods -n kube-system -w
```

> What happened? How quickly did the pod come back? Who recreated it?

---

## 3. Static pod manifests on disk

```bash
docker exec kind-control-plane ls /etc/kubernetes/manifests/
```

> How many files are there? What are they named?

```bash
docker exec kind-control-plane cat /etc/kubernetes/manifests/etcd.yaml
```

> This is a plain pod manifest — no Deployment, no ReplicaSet. Find these fields:
> - What is the `hostNetwork` setting?
> - What volumes are mounted?
> - What command-line flags is etcd started with?

```bash
docker exec kind-control-plane cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

> Find the `--etcd-servers` flag. What address does the API server use to talk to etcd?
> Find `--service-cluster-ip-range`. What is the Service CIDR?
> Find `--authorization-mode`. What authorization modes are enabled?

```bash
docker exec kind-control-plane cat /etc/kubernetes/manifests/kube-controller-manager.yaml
```

> Find `--cluster-cidr`. What is the pod network CIDR?
> Why does the controller-manager need a kubeconfig?

```bash
docker exec kind-control-plane cat /etc/kubernetes/manifests/kube-scheduler.yaml
```

> The scheduler is the simplest static pod. What is its job?

---

## 4. How kubelet manages static pods

```bash
docker exec kind-control-plane cat /var/lib/kubelet/config.yaml | grep -A 3 staticPod
```

> What path does kubelet watch for static pod manifests? If you add a file to that directory, what happens?

```bash
docker exec kind-control-plane systemctl status kubelet 2>/dev/null | head -15 || \
  docker exec kind-control-plane ps aux | grep kubelet
```

> kubelet runs as a process directly on the node, not as a pod. Why? What would happen if kubelet itself ran inside a pod?

---

## 5. PKI — Kubernetes certificate structure

```bash
docker exec kind-control-plane ls /etc/kubernetes/pki/
docker exec kind-control-plane ls /etc/kubernetes/pki/etcd/
```

> How many certificates and keys exist? Which ones are CA certs (end in `ca.crt`)?

```bash
docker exec kind-control-plane openssl x509 \
  -in /etc/kubernetes/pki/apiserver.crt \
  -noout -subject -issuer -dates
```

> Who issued the API server certificate? What is its Subject Alternative Name?

```bash
docker exec kind-control-plane openssl x509 \
  -in /etc/kubernetes/pki/apiserver.crt \
  -noout -text | grep -A 5 "Subject Alternative Name"
```

> The API server cert must include every hostname and IP that clients might use to reach it.
> What names do you see?

```bash
docker exec kind-control-plane openssl x509 \
  -in /etc/kubernetes/pki/ca.crt \
  -noout -subject -dates
```

> What is the expiry of the root CA? Why does the CA have a much longer expiry than component certs?

---

## 6. Check all cert expiry with kubeadm

```bash
docker exec kind-control-plane kubeadm certs check-expiration
```

> Find these in the output:
> - Which certificate expires soonest?
> - What is the expiry of the root CA vs the component certs?
> - Does the etcd section have separate certs?

On the CKA exam, this is the command you run when asked to check certificate expiry.

---

## 7. kubeconfig files

```bash
docker exec kind-control-plane ls /etc/kubernetes/
```

> Find the kubeconfig files (`.conf` extension). Who is each one for?

```bash
docker exec kind-control-plane cat /etc/kubernetes/admin.conf
```

> Find and explain:
> - `server:` — what does this point to?
> - `certificate-authority-data:` — what is this (decode a few chars)?
> - `client-certificate-data:` and `client-key-data:` — who authenticates with these?

Compare to your local kubeconfig:

```bash
kubectl config view --minify
```

> How is your local kubeconfig different from `admin.conf`? What did kind do to set it up for you?

---

## 8. How worker nodes join

```bash
docker exec kind-control-plane kubeadm token list
```

> Are there any active tokens? Bootstrap tokens are used by `kubeadm join` so worker nodes can authenticate with the API server.

```bash
kubectl get configmap cluster-info -n kube-public -o yaml
```

> `cluster-info` is a public ConfigMap (readable without authentication) that tells joining nodes the cluster's API server address. Where does a new worker node look to find this?

---

## 9. Kubelet on a worker node

```bash
docker exec kind-worker cat /var/lib/kubelet/config.yaml | grep -E "clusterDNS|clusterDomain|staticPodPath"
```

> Does the worker node have a staticPodPath configured? What is the DNS cluster address?

```bash
docker exec kind-worker ls /etc/kubernetes/
```

> Compare the files on the worker node to the control-plane node. What's missing on the worker?

---

## 10. Map kubeadm phases to what you observed

`kubeadm init` runs in phases:

| Phase | What it does |
|-------|-------------|
| preflight | checks host requirements |
| certs | generates PKI in `/etc/kubernetes/pki/` |
| kubeconfig | generates kubeconfig files in `/etc/kubernetes/` |
| etcd | generates static pod manifest for etcd |
| control-plane | generates static pod manifests for apiserver, controller-manager, scheduler |
| kubelet-start | writes kubelet config, starts kubelet |
| upload-config | stores kubeadm config as a ConfigMap in kube-system |
| upload-certs | stores certs as a Secret for control-plane HA joins |
| mark-control-plane | taints and labels the control-plane node |
| bootstrap-token | creates the bootstrap token for `kubeadm join` |
| addons | installs CoreDNS and kube-proxy |

For each phase, identify the artifact it created that you observed in this lab.

> Example: Phase `certs` → `/etc/kubernetes/pki/` directory
> Fill in the rest.
