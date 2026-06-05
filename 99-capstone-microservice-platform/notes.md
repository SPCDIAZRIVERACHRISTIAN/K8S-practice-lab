# Lab Notes — 99 Capstone: Microservice Platform

---

## Before you begin

> What gaps do you expect to find in your knowledge going into this lab? Which phases are you most confident about?

---

## Phase 1: Deployment

**Why does the headless Service need to be created before the StatefulSet?**

> Write your answer here.

**Why is the RBAC applied before the backend Deployment, not after?**

> Write your answer here.

**What order do you apply resources in a production GitOps pipeline? How is that different from what you did here?**

> Write your answer here.

---

## Phase 2: Service discovery

**Did frontend → backend connectivity work on the first try? If not, what did you diagnose?**

> Write your answer here.

**What three DNS forms can the frontend use to reach the backend? Which is the most explicit and portable?**

> Write your answer here.

**What DNS name does the database StatefulSet pod (`db-0`) have? What makes this different from a Deployment pod?**

> Write your answer here.

**Were the ConfigMap and Secret values correctly injected as environment variables in the backend pod?**

> Write your answer here.

---

## Phase 3: RBAC

**Fill in the RBAC audit results:**

| Permission | Result (yes/no) |
|-----------|-----------------|
| list configmaps in capstone | |
| list pods in capstone | |
| delete deployments in capstone | |
| list configmaps in default | |

**What does the result for `default` namespace tell you about Role vs ClusterRole scope?**

> Write your answer here.

---

## Phase 4: Scaling

**What CPU utilization did the HPA report before load generation?**

> Write your answer here.

**How long did it take for the HPA to scale up after load started? How long to scale back down?**

> Write your answer here.

**With 3 replicas and minAvailable: 2, what was ALLOWED DISRUPTIONS? Show the math.**

> Write your answer here.

---

## Phase 5: Rolling update

**How did the rolling update proceed with 2 replicas? Was the backend ever completely unavailable?**

> Write your answer here.

**What revision number was the deployment at after the rollback?**

> Write your answer here.

---

## Phase 6: Node maintenance

**Did the drain of kind-worker succeed immediately or did it block? Why?**

> Write your answer here.

**After draining, where did all capstone pods land? What did this tell you about the remaining node's capacity?**

> Write your answer here.

---

## Phase 7: Kustomize

**What namePrefix was added to the dev deployment? What was the final deployment name?**

> Write your answer here.

**How did the dev and prod overlays differ? List all the differences.**

> Write your answer here.

---

## Phase 8: Troubleshooting

**What failure mode was the broken-frontend deployment in? What was the root cause?**

> Write your answer here.

**What kubectl command first revealed the problem?**

> Write your answer here.

**How did you fix it?**

> Write your answer here.

---

## Phase 9: etcd backup

**Record from the snapshot status output:**

- Revision number:
- Total keys:
- Database size:

**How does the revision number compare to the number you saw in lab 23? Is it higher or lower? Why?**

> Write your answer here.

---

## Overall reflection

**Which phase was most challenging? Why?**

> Write your answer here.

**Which Kubernetes concept do you feel you understand most deeply after completing this lab series?**

> Write your answer here.

**Which concept do you still need to review before the CKA exam?**

> Write your answer here.

**If you were to deploy this platform in a production environment, what three things would you add or change?**

> Write your answer here.
