# Lab 32 — CKA Speed Troubleshooting: Tasks

**Total target time:** 35 minutes  
**Namespace:** `speed-32`

**Before starting:** Apply all manifests in `setup/` and wait 30 seconds. Do not read the setup manifests.

Start your timer when you begin Task 1.

---

## Task 1 [target: 5 min]

**Namespace:** speed-32  
**Observation:** Deployment `app-a` has pods stuck in `ImagePullBackOff`.  
**Task:** Find and fix the root cause. The deployment should have 2 Running pods.

---

## Task 2 [target: 5 min]

**Namespace:** speed-32  
**Observation:** Deployment `app-b` has 2 Running pods, but service `app-b-svc` has no endpoints.  
**Task:** Find and fix the root cause. The service should have endpoints matching the `app-b` pods.

---

## Task 3 [target: 7 min]

**Namespace:** speed-32  
**Observation:** Pod `app-c` is in `CreateContainerConfigError`.  
**Task:** Find and fix the root cause. The pod should be Running.

---

## Task 4 [target: 5 min]

**Namespace:** speed-32  
**Observation:** Pod `app-d` is stuck in `Pending`.  
**Task:** Find and fix the root cause. The pod should be Running.

---

## Task 5 [target: 8 min]

**Namespace:** speed-32  
**Observation:** Deployment `app-e` has a pod that starts but is repeatedly restarted (restart count is climbing).  
**Task:** Find and fix the root cause. The deployment should have 1 Running pod with a stable restart count.

---

## Time check

Record your finish time. Open `notes.md` and fill in your reflection.
