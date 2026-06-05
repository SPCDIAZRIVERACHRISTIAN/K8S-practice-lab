# Solutions — 21 CRDs & Operators Intro

---

## What a CRD does

A CustomResourceDefinition (CRD) extends the Kubernetes API by registering a new resource type. Once a CRD is applied, the API server starts accepting, storing, and serving objects of that type — just like built-in resources.

Technically, the API server dynamically generates REST endpoints for the new resource:
```
GET    /apis/lab.example.com/v1/namespaces/{ns}/widgets
POST   /apis/lab.example.com/v1/namespaces/{ns}/widgets
GET    /apis/lab.example.com/v1/namespaces/{ns}/widgets/{name}
PUT    /apis/lab.example.com/v1/namespaces/{ns}/widgets/{name}
DELETE /apis/lab.example.com/v1/namespaces/{ns}/widgets/{name}
```

Custom resources are stored in etcd alongside built-in resources. They support all standard operations: `get`, `list`, `watch`, `patch`, `delete`. They can be protected by RBAC, written to audit logs, and watched via the Kubernetes watch API.

---

## CRD spec sections

A CRD has three main sections:

**`spec.names`** — Defines the resource's names: `plural` (for URL paths and `kubectl get`), `singular` (for `kubectl describe`), `kind` (for YAML `kind:` field), `shortNames` (for convenience).

**`spec.versions`** — Defines the API versions (e.g., `v1`, `v1alpha1`, `v1beta1`). Each version has its own schema. A CRD can serve multiple versions simultaneously during migrations.

**`spec.scope`** — `Namespaced` (lives in a namespace, like Pod) or `Cluster` (not namespaced, like Node, PersistentVolume).

---

## Schema validation

The `openAPIV3Schema` field in the CRD defines what valid custom resources look like. The Kubernetes API server validates every create and update against this schema at admission time — before the resource is stored in etcd.

**widget-invalid-color.yaml:** `color: purple` — the schema defines `enum: ["red", "blue", "green"]`. Purple is not in the enum. The API server rejects it with:
```
The Widget "broken-color" is invalid: spec.color: Unsupported value: "purple": supported values: "red", "blue", "green"
```

**widget-invalid-size.yaml:** `size: 999` — the schema defines `maximum: 100`. The API server rejects it with:
```
The Widget "broken-size" is invalid: spec.size: Invalid value: 999: spec.size in body should be less than or equal to 100
```

**widget-missing-required.yaml:** Both `color` and `size` are in `required: ["color", "size"]`. The API server rejects it with:
```
The Widget "broken-required" is invalid: [spec.color: Required value, spec.size: Required value]
```

**Without a schema:** If `openAPIV3Schema` is omitted, the API server applies no field-level validation. Any YAML can be stored as a Widget. This is dangerous for production — use a schema.

---

## additionalPrinterColumns

The `additionalPrinterColumns` field defines what `kubectl get widgets` shows:

```yaml
additionalPrinterColumns:
- name: Color
  type: string
  jsonPath: .spec.color
```

`jsonPath` is a JSONPath expression evaluated against each resource's full YAML. The result becomes a column value. Without this, `kubectl get widgets` only shows Name, Age, and Namespace.

This is purely cosmetic — it does not affect what is stored or validated.

---

## The CRD vs operator distinction

**CRD alone = a database table definition.**

When you create a Widget resource:
- The API server validates it against the schema
- If valid, it stores it in etcd
- Nothing else happens

Compare this to creating a Deployment:
- The API server stores the Deployment in etcd
- The Deployment controller (part of kube-controller-manager) watches for new Deployments
- It creates a ReplicaSet
- The ReplicaSet controller creates Pods
- The Scheduler assigns each Pod to a node
- kubelet starts the container

A Deployment has a **controller** watching for changes and driving the cluster toward the desired state. A plain CRD does not.

**An operator is a CRD + a controller.**

The controller:
1. Watches for create/update/delete events on the custom resource (using the Kubernetes watch API)
2. Reads the resource's `spec` (what you want)
3. Inspects the cluster's current state
4. Takes actions to reconcile current state → desired state
5. Updates the resource's `status` with what actually happened

This reconcile loop is the core of the operator pattern. The controller encodes operational knowledge: how to bootstrap, scale, upgrade, backup, and recover the application.

### Real-world operator examples

| Operator | What it manages |
|----------|----------------|
| cert-manager | Certificates, CertificateRequests — provisions TLS certs from Let's Encrypt |
| Prometheus Operator | Prometheus instances, ServiceMonitors, PrometheusRules |
| Strimzi (Kafka) | Kafka clusters, Topics, Users, Connectors |
| PostgreSQL Operator (CNPG) | PostgreSQL clusters, Backups, Poolers |
| ArgoCD | Applications (maps Git branches to cluster state) |

Each defines one or more CRDs and runs a controller deployment in the cluster.

---

## Deleting the CRD

When you delete a CRD, all custom resources of that type are also deleted from etcd. The CRD is the schema that gives meaning to the stored data — without it, the data cannot be interpreted or served.

This means: if you delete a CRD that has live resources, those resources are gone. This is irreversible if you do not have a backup. In production, operators typically protect the CRD with finalizers or admission webhooks to prevent accidental deletion.

---

## How Kubernetes extends itself

Many "built-in" Kubernetes resources are defined using the same extension mechanism as CRDs. NetworkPolicy, IngressClass, and CSIDriver are examples of resources that were added to Kubernetes over time through the API extension mechanism. The line between "core Kubernetes" and "extended Kubernetes" has blurred as the API has grown.

This means the extension model (CRDs + controllers) is not just for third-party software — it is how Kubernetes itself evolves.

---

## CKA relevance

CRDs appear on the CKA at a conceptual level. You may be asked to:
- Apply a CRD from a manifest file
- Create custom resources using `kubectl apply`
- Inspect CRD schemas with `kubectl describe crd`
- Query custom resources with `kubectl get <kind>`

You are not expected to write CRD schemas or operator code from scratch on the exam.
