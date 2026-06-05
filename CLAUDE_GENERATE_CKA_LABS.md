# Claude Instruction File — Generate the Rest of the Kubernetes / CKA Practice Labs

Use this file as the prompt/instruction set for Claude or any coding assistant that will extend this repository.

The goal is to turn this repository into a structured, hands-on Kubernetes training lab that starts from basic mental models and progresses toward Certified Kubernetes Administrator (CKA)-level operational skill.

This repo should not become a command dump. Every lab must force the learner to run commands, observe behavior, break something, fix it, and explain the concept in their own words.

---

## Current Repository Context

The repo currently has:

```text
K8S-practice-lab-main/
├── README.md
├── kubernetes-info.md
├── observability-tools-notes.md
├── assets/
│   └── cluster-diagram.png
└── 00-kind-cluster/
    ├── README.md
    ├── cleanup.sh
    ├── commands.md
    ├── kind-config.yaml
    └── notes.md
```

The existing `00-kind-cluster` lab is the starting point. Preserve the style, but improve it where necessary.

Important fix:

```yaml
nodes:
  - role: control-plane
  - role: worker1
  - role: worker2
```

should be corrected to:

```yaml
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

kind node roles are `control-plane` and `worker`. Do not use `worker1` or `worker2` as role values.

---

## Training Philosophy

Build this repo for someone who wants real Kubernetes operating skill, not just copied commands.

Every lab must follow this learning loop:

```text
Concept
  ↓
Manifest/object
  ↓
Apply/run
  ↓
Observe
  ↓
Break
  ↓
Troubleshoot
  ↓
Fix
  ↓
Explain in notes
  ↓
Clean up
```

Do not over-explain everything in the lab notes. The notes should ask questions and leave room for the learner to answer.

Avoid turning the repo into a tutorial where the answer is already given. Give enough guidance to move forward, but make the learner do the thinking.

---

## CKA Alignment

Align the labs with the current CKA domains:

```text
Cluster Architecture, Installation & Configuration — 25%
Services & Networking — 20%
Workloads & Scheduling — 15%
Storage — 10%
Troubleshooting — 30%
```

The CKA is performance-based. Design labs as command-line tasks, scenario repairs, and timed drills.

Assume the learner is using:

```text
Docker
kind
kubectl
Linux/macOS shell
```

When a concept cannot be fully simulated in kind, still create a lab that explains the limitation and gives a reasonable local approximation.

---

## Required Lab Folder Format

Every lab folder must use this structure:

```text
XX-lab-name/
├── README.md
├── manifests/
│   └── *.yaml
├── commands.md
├── notes.md
├── cleanup.sh
└── solutions.md
```

For labs that need scripts, add:

```text
scripts/
```

For labs that intentionally include broken manifests, add:

```text
broken/
```

For labs with fixed versions, add:

```text
fixed/
```

Example:

```text
15-troubleshoot-service-networking/
├── README.md
├── broken/
│   ├── deployment.yaml
│   └── service.yaml
├── fixed/
│   ├── deployment.yaml
│   └── service.yaml
├── commands.md
├── notes.md
├── cleanup.sh
└── solutions.md
```

---

## Required File Behavior

### README.md

Each lab README must include:

```text
# XX — Lab Title

Goal:
What this lab teaches:
Prerequisites:
What you will build:
Files:
Success criteria:
Estimated difficulty:
```

Also include a small architecture diagram using plain text when helpful.

### commands.md

This file should include the commands the learner should run.

For beginner labs, commands may be more explicit.

For intermediate labs, include some partial hints.

For advanced labs, use scenario prompts instead of spoon-feeding all commands.

Example beginner style:

```bash
kubectl get pods -A -o wide
```

Example advanced style:

```text
Find why the backend service has no reachable endpoints.
Use only kubectl inspection commands first.
Do not open the solution until you can explain the failure.
```

### notes.md

This file is for learner answers.

It should have questions, blanks, and observation prompts.

Do not fill it with final answers.

Use this format:

```md
# Lab Notes — XX Lab Title

## What I Expected

> Write your answer here.

## What Actually Happened

> Write your answer here.

## Commands I Used

> Write your answer here.

## What This Means

> Write your answer here.

## Break/Fix Reflection

> Write your answer here.

## Things I Still Need to Research

> Write your answer here.
```

### solutions.md

This file should include:

```text
Expected observations
Common mistakes
Corrected manifests if needed
Explanation of the fix
```

Keep solutions separate so learners do not accidentally see the answer while taking notes.

### cleanup.sh

Every lab must include a safe cleanup script.

Rules:

1. Use `set -euo pipefail`.
2. Delete only resources created by that lab.
3. Prefer namespace deletion when the lab uses a dedicated namespace.
4. Do not delete the whole kind cluster except in cluster lifecycle labs.
5. Print what is being cleaned.

Example:

```bash
#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace lab-01-pods --ignore-not-found=true
```

---

## Difficulty Progression

Create the labs in this order.

### Phase 0 — Foundation: Cluster Mental Model

#### 00-kind-cluster

Status: already exists. Improve only as needed.

Focus:

```text
kind
cluster
control plane node
worker nodes
kubectl context
system pods
Docker containers as kind nodes
```

Tasks:

```text
Create a multi-node kind cluster.
Inspect nodes.
Inspect system pods.
Describe control-plane and worker nodes.
Explain why opening the API server URL in the browser returns system:anonymous / 403 Forbidden.
Delete and recreate the cluster.
```

---

### Phase 1 — Core Objects and Workloads

#### 01-pods

Focus:

```text
Pod object
manifest vs object
container inside pod
pod lifecycle
logs
exec
port-forward
```

Build:

```text
One nginx pod in its own namespace.
```

Break/Fix:

```text
Use a bad image tag and observe ImagePullBackOff.
Fix the image.
Delete the pod and observe that it does not come back automatically.
```

#### 02-deployments-replicasets

Focus:

```text
Deployment
ReplicaSet
self-healing
replicas
labels
selectors
```

Build:

```text
Deployment with 3 replicas.
```

Break/Fix:

```text
Delete one managed pod and observe recreation.
Scale from 3 to 5, then down to 2.
Break labels/selectors and observe what happens.
```

#### 03-rollouts-rollbacks

Focus:

```text
rolling updates
rollout status
rollout history
rollback
image updates
```

Build:

```text
Deployment using nginx or http-echo.
```

Break/Fix:

```text
Update to a broken image.
Observe rollout failure.
Rollback to previous revision.
```

#### 04-configmaps-secrets-env

Focus:

```text
ConfigMap
Secret
environment variables
mounted config files
base64 encoding caveat
```

Build:

```text
A pod or deployment that reads normal config from a ConfigMap and sensitive-like config from a Secret.
```

Break/Fix:

```text
Reference a missing ConfigMap key.
Reference a missing Secret.
Fix both.
```

#### 05-healthchecks-probes

Focus:

```text
readinessProbe
livenessProbe
startupProbe
container health
service endpoint readiness
```

Build:

```text
Simple web app container with readiness/liveness probes.
```

Break/Fix:

```text
Misconfigure probe path or port.
Observe pod restarts or service endpoint removal.
Fix probes.
```

---

### Phase 2 — Networking

#### 06-services-clusterip-nodeport

Focus:

```text
ClusterIP
NodePort
Service selectors
Endpoints/EndpointSlices
pod IP instability
stable service access
```

Build:

```text
Deployment + ClusterIP service.
Then expose with NodePort.
```

Break/Fix:

```text
Break service selector.
Observe service has no endpoints.
Fix selector.
```

#### 07-dns-coredns-service-discovery

Focus:

```text
CoreDNS
service DNS names
namespace-aware DNS
short names vs FQDN
```

Build:

```text
Frontend pod curls backend service by DNS name.
```

Break/Fix:

```text
Try wrong namespace DNS.
Fix with correct FQDN.
Inspect CoreDNS pods and logs.
```

#### 08-ingress-and-gateway-api-intro

Focus:

```text
Ingress controller
Ingress resource
HTTP host/path routing
Gateway API awareness
```

Build:

```text
Install an ingress controller suitable for kind.
Expose frontend/backend paths.
```

Break/Fix:

```text
Wrong service name or port in Ingress.
Fix routing.
```

Note:

```text
Include a short conceptual comparison between Ingress and Gateway API, but do not overbuild Gateway API unless it works cleanly in kind.
```

#### 09-network-policies

Focus:

```text
NetworkPolicy
pod isolation
ingress rules
egress rules
labels/selectors
CNI limitation awareness
```

Build:

```text
Backend service that only frontend can reach.
```

Break/Fix:

```text
Deny all ingress.
Allow only pods with app=frontend.
Test from allowed and denied pods.
```

Important:

```text
If kind's default networking does not enforce NetworkPolicy, include instructions to install a compatible CNI such as Calico for this lab or clearly document the limitation.
```

---

### Phase 3 — Scheduling and Resource Management

#### 10-namespaces-labels-selectors

Focus:

```text
namespaces
labels
selectors
annotations
kubectl filtering
```

Build:

```text
Multiple namespaces with similarly named apps.
```

Break/Fix:

```text
Use wrong namespace and observe missing resources.
Use labels to find resources across namespaces.
```

#### 11-resource-requests-limits

Focus:

```text
CPU/memory requests
CPU/memory limits
QoS classes
OOMKilled
scheduling constraints
```

Build:

```text
Pods with requests and limits.
```

Break/Fix:

```text
Create an unschedulable pod with excessive requests.
Create a pod that exceeds memory limit and observe OOMKilled.
```

#### 12-node-selectors-affinity-taints-tolerations

Focus:

```text
node labels
nodeSelector
node affinity
taints
tolerations
control-plane taint awareness
```

Build:

```text
Schedule workloads to specific kind worker nodes.
```

Break/Fix:

```text
Apply a taint to a worker.
Observe pod pending.
Add toleration.
Fix placement.
```

#### 13-daemonsets-jobs-cronjobs

Focus:

```text
DaemonSet
Job
CronJob
batch workloads
node-level agents
```

Build:

```text
DaemonSet that runs one pod per node.
Job that completes successfully.
CronJob that runs on a schedule.
```

Break/Fix:

```text
Broken command in Job.
Fix and rerun.
Suspend/resume CronJob.
```

#### 14-autoscaling-hpa-basics

Focus:

```text
HorizontalPodAutoscaler
metrics-server
CPU-based scaling
resource requests requirement
```

Build:

```text
Install metrics-server in kind if possible.
Create HPA for a deployment.
Generate load.
Observe scaling.
```

Break/Fix:

```text
Remove CPU requests and observe HPA cannot calculate metrics.
Fix requests.
```

---

### Phase 4 — Storage

#### 15-volumes-emptydir-hostpath

Focus:

```text
emptyDir
hostPath
pod restart behavior
node-local storage limitation
```

Build:

```text
Pod writing data to emptyDir.
Pod using hostPath in kind.
```

Break/Fix:

```text
Delete pod and compare what survives.
Explain why local node storage is not the same as durable cluster storage.
```

#### 16-pv-pvc-storageclass

Focus:

```text
StorageClass
PersistentVolume
PersistentVolumeClaim
dynamic provisioning
access modes
reclaim policy
```

Build:

```text
PVC using kind's local-path provisioner.
Pod mounts PVC.
```

Break/Fix:

```text
Request impossible storage class.
Observe Pending PVC.
Fix storageClassName.
Delete PVC and observe reclaim behavior.
```

#### 17-statefulsets

Focus:

```text
StatefulSet
stable pod identity
stable network identity
volumeClaimTemplates
ordered rollout
```

Build:

```text
Small StatefulSet, preferably using nginx or a lightweight database-like demo.
```

Break/Fix:

```text
Scale up/down and observe pod names and PVCs.
Delete one pod and observe identity preserved.
```

---

### Phase 5 — Security, Access, and Cluster Administration

#### 18-rbac-serviceaccounts

Focus:

```text
ServiceAccount
Role
RoleBinding
ClusterRole
ClusterRoleBinding
least privilege
kubectl auth can-i
```

Build:

```text
ServiceAccount that can list pods in one namespace but cannot delete deployments.
```

Break/Fix:

```text
Create insufficient permissions.
Use kubectl auth can-i to prove failure.
Fix Role/RoleBinding.
```

#### 19-security-contexts-admission-basics

Focus:

```text
securityContext
runAsNonRoot
readOnlyRootFilesystem
capabilities
Pod Security Admission awareness
```

Build:

```text
Pod with secure defaults.
Namespace with restricted Pod Security labels if supported.
```

Break/Fix:

```text
Try to run privileged/root pod in restricted namespace.
Observe rejection.
Fix security context.
```

#### 20-helm-kustomize

Focus:

```text
Helm install/upgrade/rollback
Kustomize bases/overlays
kubectl apply -k
```

Build:

```text
Simple app deployed with Kustomize overlays: dev and prod.
Install a small component with Helm.
```

Break/Fix:

```text
Change image/tag/replicas through overlay.
Perform Helm rollback.
```

#### 21-crds-operators-intro

Focus:

```text
CustomResourceDefinition
custom resources
operator concept
extension interfaces
```

Build:

```text
Install a very small safe CRD example.
Create a custom resource.
Inspect CRD schema.
```

Break/Fix:

```text
Create invalid custom resource and observe validation failure if schema supports it.
```

---

### Phase 6 — Cluster Lifecycle and kubeadm Concepts

#### 22-kubeadm-theory-and-kind-mapping

Focus:

```text
kubeadm init/join concepts
control plane components
certificates
static pods
etcd
kubeconfig files
```

Build:

```text
Do not force full kubeadm setup unless the learner has VMs.
Use kind control-plane node to inspect static pod manifests and component behavior.
```

Tasks:

```text
Inspect control plane pods.
Exec into kind control-plane container if needed.
Find static pod manifests.
Explain kubeadm equivalent lifecycle.
```

#### 23-backup-restore-etcd-concept-lab

Focus:

```text
etcd role
cluster state
backup/restore concept
control plane risk
```

Build:

```text
A careful concept lab around etcd in kind.
```

Rules:

```text
Do not create destructive restore steps unless they are safe and clearly isolated.
Prefer read-only inspection first.
If backup commands are included, explain that production etcd procedures require exact version/path/cert handling.
```

#### 24-upgrades-and-node-maintenance

Focus:

```text
cordon
drain
uncordon
node maintenance
PodDisruptionBudget awareness
```

Build:

```text
Deployment spread across worker nodes.
```

Break/Fix:

```text
Cordon and drain a worker.
Observe pod rescheduling.
Uncordon.
Add PDB and observe drain behavior.
```

---

### Phase 7 — Observability and Troubleshooting

#### 25-logs-events-describe-debug

Focus:

```text
kubectl logs
kubectl describe
kubectl events
kubectl exec
kubectl debug if available
container output streams
```

Build:

```text
Apps with intentional log output and failure modes.
```

Break/Fix:

```text
CrashLoopBackOff
ImagePullBackOff
CreateContainerConfigError
Pending
Service no endpoints
```

#### 26-troubleshoot-workloads

Focus:

```text
Deployment not ready
wrong image
bad command
bad env var
probe failure
resource pressure
```

Build:

```text
Several broken deployments in separate namespaces.
```

Format:

```text
Learner receives only scenario and broken manifests.
They must fix them.
Solutions are separate.
```

#### 27-troubleshoot-networking

Focus:

```text
Service selectors
ports vs targetPorts
DNS
Ingress routing
NetworkPolicy
CoreDNS
```

Build:

```text
Frontend cannot reach backend.
Backend exists but service has wrong selector.
Ingress points to wrong service port.
```

#### 28-troubleshoot-storage

Focus:

```text
PVC pending
wrong storage class
mount errors
access mode conflicts
StatefulSet PVC behavior
```

Build:

```text
Broken storage scenarios.
```

#### 29-troubleshoot-cluster-nodes

Focus:

```text
node readiness
taints
kube-system pods
resource pressure
control-plane component awareness
```

Build:

```text
Safe simulations using taints, cordon, bad scheduling constraints, and resource pressure.
```

Do not include steps that seriously damage the user's host system.

---

### Phase 8 — CKA Timed Drills

#### 30-cka-speed-basics

Focus:

```text
fast object creation
imperative kubectl
YAML generation
namespace switching
resource inspection
```

Build:

```text
Timed tasks with 5 to 10 minute limits.
```

Include:

```text
Create namespace.
Create deployment.
Expose deployment.
Scale deployment.
Set image.
Rollback.
Create ConfigMap.
Create Secret.
```

#### 31-cka-speed-networking-storage

Focus:

```text
services
DNS
ingress
PVC
storage classes
network policies
```

Build:

```text
Timed mixed tasks.
```

#### 32-cka-speed-troubleshooting

Focus:

```text
broken cluster/app scenarios
triage speed
root cause identification
minimal correct fix
```

Build:

```text
A set of broken scenarios with expected fixes.
```

Rules:

```text
No hints in the main task file.
Hints file optional.
Solutions separate.
```

#### 33-mock-exam-01

Focus:

```text
Full CKA-style practice run.
```

Build:

```text
15 to 20 tasks.
2 hour limit.
Mixed difficulty.
No explanations in task file.
Separate solutions.
```

#### 34-mock-exam-02-hard

Focus:

```text
Harder full CKA-style practice run.
```

Build:

```text
15 to 20 tasks.
2 hour limit.
More troubleshooting-heavy.
```

---

### Phase 9 — Capstone

#### 99-capstone-microservice-platform

Focus:

```text
end-to-end Kubernetes administration
multi-service app
networking
storage
configuration
rollouts
scheduling
RBAC
observability
troubleshooting
```

Build:

```text
One kind multi-node cluster.
One application namespace.
Frontend deployment.
Backend deployment.
Database/stateful component.
Services.
Ingress.
ConfigMap.
Secret.
PVC.
Probes.
Resource requests/limits.
RBAC service account.
NetworkPolicy.
Rollout/rollback task.
Troubleshooting scenario.
```

The capstone should be usable as a demo project and a final review lab.

---

## Root README Update Required

Update the root `README.md` with:

```text
Project goal
Prerequisites
How to create the kind cluster
How to run labs
How to clean up
Lab roadmap table
CKA domain mapping
Recommended study flow
Warning that notes.md files are intentionally blank/question-based
```

The lab roadmap table should include:

```text
Lab number
Folder
Topic
Difficulty
CKA domain
Status
```

Use difficulty labels:

```text
Beginner
Easy
Medium
Hard
Exam-style
Capstone
```

---

## Add a CKA Domain Mapping File

Create:

```text
CKA_DOMAIN_MAP.md
```

Include a table mapping every lab to one or more CKA domains.

Example:

```md
| Lab | Topic | Cluster Arch 25% | Networking 20% | Workloads 15% | Storage 10% | Troubleshooting 30% |
|---|---|---:|---:|---:|---:|---:|
| 00 | kind cluster | ✅ |  |  |  | ✅ |
| 01 | pods |  |  | ✅ |  | ✅ |
```

Also include a recommended order for:

```text
first pass
second pass
exam-speed pass
```

---

## Add a Learner Workflow File

Create:

```text
HOW_TO_USE_THIS_REPO.md
```

Include:

```text
1. Create or confirm kind cluster.
2. Enter the lab folder.
3. Read README.md.
4. Apply manifests or run commands.
5. Observe outputs.
6. Answer notes.md.
7. Run break/fix section.
8. Check solutions.md only after attempting.
9. Run cleanup.sh.
10. Commit personal notes if using private fork.
```

Also include this rule:

```text
Do not memorize commands blindly. For every command, write what object/resource it inspected or changed.
```

---

## Add Notes Reset / Fork Cleanup System

This is required as the final step.

The repo owner may fill `notes.md` files with personal learning notes while studying. But anyone who forks the repo should be able to reset notes files back to clean templates.

Implement one of these systems:

Preferred system:

```text
templates/
└── notes-template.md

scripts/
└── reset-notes.sh
```

`templates/notes-template.md` should contain:

```md
# Lab Notes — <LAB_TITLE>

## What I Expected

> Write your answer here.

## What Actually Happened

> Write your answer here.

## Commands I Used

> Write your answer here.

## Objects or Resources I Touched

> Write your answer here.

## What Changed in the Cluster

> Write your answer here.

## What Broke

> Write your answer here.

## How I Fixed It

> Write your answer here.

## What This Means

> Write your answer here.

## Things I Still Need to Research

> Write your answer here.
```

`scripts/reset-notes.sh` should:

```text
Find every lab folder matching NN-*.
Replace that lab's notes.md with a clean template.
Customize the title using the folder name if possible.
Ask for confirmation unless run with --yes.
Never delete solutions.md, manifests, or README.md.
```

Also add:

```text
scripts/clean-personal-notes.sh
```

This can be an alias/wrapper around `reset-notes.sh`, or it can do the same thing. The purpose is clarity for people who fork the repo.

Add root README instructions:

```bash
./scripts/reset-notes.sh
```

and:

```bash
./scripts/reset-notes.sh --yes
```

Expected behavior:

```text
Before publishing or sharing the repo, run reset-notes.sh so learners get blank notes.md files.
Learners can then fork the repo and write their own research, observations, and answers.
```

---

## Style Rules

Keep tone direct and practical.

Use simple language.

Do not create giant walls of theory.

Each lab should have just enough concept explanation to make the hands-on task meaningful.

Use plain diagrams when helpful:

```text
Client
  ↓
Ingress
  ↓
Service
  ↓
Pod
  ↓
Container
```

Do not use screenshots unless necessary.

Do not depend on cloud providers.

Do not require paid tools.

Do not require Helm charts from random untrusted sources.

Prefer official Kubernetes images, nginx, busybox, registry.k8s.io images, or small demo containers.

---

## Safety and Host System Rules

The labs must not damage the user's host machine.

Do not include commands that:

```text
wipe Docker globally
remove unrelated containers/images/volumes
change host firewall permanently
modify system-wide networking outside kind
require sudo unless clearly justified
```

Avoid:

```bash
docker system prune -a --volumes
rm -rf /var/lib/*
```

All cleanup scripts must be scoped to lab-created Kubernetes resources or named kind clusters.

---

## Quality Bar

The completed repo should let a learner go from:

```text
I know clusters, nodes, pods, and YAML are related somehow.
```

to:

```text
I can operate Kubernetes under pressure, inspect resources, repair broken workloads, reason through networking/storage/scheduling/RBAC issues, and perform CKA-style tasks from the command line.
```

A learner who completes all labs honestly should be very well prepared for the CKA exam, but do not promise a guaranteed score. Aim the difficulty and coverage toward a strong 90%+ preparation level.

---

## Final Deliverables Claude Should Produce

When extending the repo, produce:

```text
01-pods/ through 34-mock-exam-02-hard/
99-capstone-microservice-platform/
CKA_DOMAIN_MAP.md
HOW_TO_USE_THIS_REPO.md
templates/notes-template.md
scripts/reset-notes.sh
scripts/clean-personal-notes.sh
updated root README.md
```

Before finishing, verify:

```text
All cleanup.sh files are executable.
All YAML files parse.
All lab folders follow the required structure.
No notes.md file contains the original author's personal answers.
No solution is placed inside notes.md.
Root README has a complete lab roadmap.
```

