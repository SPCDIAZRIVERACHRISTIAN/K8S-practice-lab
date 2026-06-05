# Lab Notes — Answer These After Running the Commands

Fill in your answers after completing the lab. These are not tricks — they are the things you should be able to say out loud without hesitation before moving on.

---

**What is the cluster name?**

> my-first-cluster

---

**How many nodes exist?**

> 3

---

**Which node is the control plane?**

> control-plane

---

**Which nodes are workers?**

> worker1, worker2

---

**What command shows all nodes?**

> kubectl get nodes

---

**What command shows detailed node info?**

> kubectl describe node <node name> and kubectl get nodes -o wide for a detailed list like ls -la

---

**What happens when you delete the cluster?**

> (Think about: is the data gone? Can you recreate it? What about kubectl context?)

---

**What did you notice that was different between describing the control-plane node vs a worker node?**

> It has way more pods than a worker node this is because it depends on kube-system pods to manage the workers control plane sole purpose is to make sure everything is up good and ready to go while workers are tasked with providing the services you tasked them.

---

**Anything that confused you or that you want to research further?**

> not now.

---

## To run a cluster in kind use:

```bash
kind create cluster --config <filename>.yaml
```

## To get info on kind:

```bash
kubectl cluster-info --context <cluster name>
```

- when you type the cluster-info command the command gives you the URL to access your "backend" or so to speak of the cluster. This link will show you forbidden access on your browser because it is not meant to be seen by the browser.

## Kubernetes API:

- when working with kubernetes api this is just a group of apis that authenticate you as the dev or owner of a cluster and lets you inspect through multiple tools such as kubectl to monitor create or delete clusters, nodes and pods.

## Nodes:

- This is a machine inside the kubernetes cluster it could be a VM, physical server, cloud VM or docker container pretending to be a VM (kind)

- nodes are a group of pods this could be system pods like kube-proxy or etcd and app pods which is where your app lives.

## Objects:

- Objects are basically yaml or json files specifying behavior 
### Example: 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx
```

- You can look at object as a sort of configuration manifest for multiple things like:

Pod

Deployment

Service

ConfigMap

Secret 

Namespace 

Node 

Ingress 

Job 
