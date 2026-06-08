# Lab Notes — 02 Deployments and ReplicaSets

Answer each question after running the lab.

---

## What I Expected

> What did you think a Deployment did before this lab?
> I really did not know a deployment type? existed I just thought you ran whatever app in prod mode thats it now I know to checkout deployment docs in kubernetes.

---

## What Actually Happened

> Describe what happened when you applied the Deployment. What objects appeared?
> So when I applied Deployment it used the manifest to add app label, 3 pods of the same template to make it scalable. It also protects the app from being down by recreating a pod as soon as one fails or is deleted.
---

## Commands I Used

> List the commands you ran and what each one showed you.
> kubectl get deployment -n lab-02-deployments
> kubectl describe deployment nginx-deployment -n lab-02-deployments
> kubectl create namespace lab-02-deployments
> kubectl apply -f manifests/deployment.yaml
> kubectl get pods -n lab-02-deployments -w
> kubectl get replicaset -n lab-02-deployments
> kubectl describe replicaset -n lab-02-deployments

---

## Objects or Resources I Touched

> What Kubernetes objects were created in this lab?

> I didnt touch any objects on this one if you mean resources as in documentation I used deployments kind documentation and kubectl docs to understand what apis were being used and what was it bringing back.

---

## The Deployment → ReplicaSet → Pod Chain

**What is the relationship between a Deployment, a ReplicaSet, and a Pod?**

> so Deployment is a prod ready environment doing most things environment wise needs to make your app ready for prod. ReplicaSets makes your application highly scalable it uses object template to recreate as many pods needed for your app and your pod is just a container runtime this is in charge of your app and ensures your app is being raned.

**When you deleted a pod, what created the replacement?**

> I have absolutely no idea. M.y theory is that the template specified: "hey, I need 3 pods up and running" so k8s verifies that there is always 3 seperate pods in the case one goes down for any reason it just spins up a new one but I am not sure all I know is that this only works in deployment not on normal clusters.

**How does the ReplicaSet know which pods it owns?**

> I think it keeps a record specified on Replica key where it states how many are running and how many are desired.

---

## Scaling

**What changed in the cluster when you scaled from 3 to 5?**

> it just bumped 5 pods instead of 3.

**What happened to the ReplicaSet when you scaled down?**

> it eliminated 3

---

## The Broken Selector

**What error appeared when you applied the broken selector manifest?**

> Write your answer here (paste the full error message).

**Why does Kubernetes reject a Deployment where the selector does not match the template labels?**

> Because k8s will not know where to add that deployment?

---

## What Changed in the Cluster

> The cluster ended up with 3 workers and 2 pods inside worker 2 if im not mistaken didnt check the cluster.

---

## What Broke

> The broken manifest did not specified the correct label because label did not exist k8s didnt do anything because there was no label with that name.

---

## What This Means

> Deployment just makes your app more scalable add a proxy server or load balancer on that puppy and you have a full prod fully scalable env for your app or system.

---

## Things I Still Need to Research

> kubernetes in general I have alot of trouble reading manifest and how to apply them not that its not easy I just wouldnt know how to apply one and what is a normal cluster and deployment one is there any other modes? all that.
