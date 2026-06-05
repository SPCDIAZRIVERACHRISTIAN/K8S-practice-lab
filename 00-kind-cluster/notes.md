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

> 

---

**What happens when you delete the cluster?**

> (Think about: is the data gone? Can you recreate it? What about kubectl context?)

---

**What did you notice that was different between describing the control-plane node vs a worker node?**

> 

---

**Anything that confused you or that you want to research further?**

> 

---

## To run a cluster in kind use:

```
kind create cluster --config <filename>.yaml
```

to get info on kind:

```
kubectl cluster-info --context <cluster name>
```
