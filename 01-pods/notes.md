# Lab Notes — 01 Pods

Answer each question after running the lab. Write in your own words.

---

## What I Expected

> What did you think a pod was before this lab? How did your mental model change?

I did not have any expectations of what a pod was I didnt understand them until I started working with it 

---

## What Actually Happened

> Describe the pod lifecycle you observed. What states did it move through?

it first went to ContainerCreate or something along those lines and then ContainerReady 

---

## Commands I Used

> List the commands you ran. For each one, write what object or resource it touched.

kubectl create namespace <namespace> - this was to create a namespace

kubectl apply -f <manifest file> - for making the pod 

kubectl get pods -n <namespace> - to see available pods

kubectl describe pod <pod name> - to see things like events, node, ip, containers and conditions.

kubectl logs nginx-pod -n lab-01-pods - to see logs inside the pod 

kubectl exec -it nginx-pod -n lab-01-pods -- /bin/bash - To ssh in to the container 

kubectl port-forward pod/nginx-pod 8080:80 -n lab-01-pods - to see app from machine.

---

## Objects or Resources I Touched

> What Kubernetes objects did you create or modify in this lab?

one cluster and a pod 

---

## Pod Inspection

**What does `kubectl describe pod` show that `kubectl get pod` does not?**

> describe gives you a detailed hashmap of important info get is really more summarized.

**What is in the `Events` section of a pod describe output?**

> important process triggered like worker processes and errors.

**Where do pod logs come from?**

> the containers its running.

---

## The Broken Pod

**What error appeared when you applied the bad image pod?**

> ImagePullBackOff

**What does `ImagePullBackOff` mean?**

> Kubernetes status indicating that a container failed to start because the kubelet could not pull the required container image from the registry.

**What is the difference between `ErrImagePull` and `ImagePullBackOff`?**

> ErrImagePull is the initial error state that occurs the first time the kubelet fails to pull the image from the registry. 
ImagePullBackOff is the subsequent status that appears after one or more failed attempts, indicating that Kubernetes is waiting with increasing delays (exponential backoff, up to 5 minutes) before retrying the pull.

---

## Self-Healing

**What happened after you deleted the nginx-pod?**

> dumb question

**Why did it not come back?**

> to dumb to answer.

**What Kubernetes object would you need to add to make a pod self-heal after deletion?**

> N/A

---

## What Changed in the Cluster

> What existed in the cluster at the end of the lab that was not there before?

---

## What Broke

> Describe the ImagePullBackOff scenario.

---

## How I Fixed It

> How did you fix the broken pod? What command(s) did you use?

---

## What This Means

> In two or three sentences: explain what a pod is and why it is the smallest deployable unit in Kubernetes.

---

## Things I Still Need to Research

> Write your answer here.
